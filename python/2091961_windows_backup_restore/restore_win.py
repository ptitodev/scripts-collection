import argparse
from os import path, close
from subprocess import call, Popen, PIPE
import sys
import os
import getopt
import shutil
import time

sys.path.append(os.environ["VMWARE_PYTHON_PATH"])
from cis.defaults import get_cis_install_dir, get_cis_log_dir
constrfilename = "create_constr" + time.strftime("%Y%m%d%H%M%S%m") + ".sql"
indexfilename = "create_index" + time.strftime("%Y%m%d%H%M%S%m") + ".sql"

VPOSTGRES_FOLDER = path.join(get_cis_install_dir(), "vPostgres")
CIS_LOG        = get_cis_log_dir()
PSQL           = path.join(VPOSTGRES_FOLDER, "bin", "psql")
PG_RESTORE     = path.join(VPOSTGRES_FOLDER, "bin", "pg_restore")
CREATE_INDEXES = path.join(CIS_LOG, indexfilename)
CREATE_CONSTRAINTS = path.join(CIS_LOG, constrfilename)
PG_PASS_FOLDER = path.join(os.environ['APPDATA'], "postgresql")
PG_PASS_FILE   = path.join(PG_PASS_FOLDER, "pgpass.conf")

fileOut = ""
fileError = ""

def psqlFile(filePath, userName = "vc", database = "VCDB"):
   return [PSQL, "-U", userName, "-d", database, "-q", "-f", filePath]

def psqlQuery(query, userName = "vc", database = "VCDB"):
   return [PSQL, "-U", userName, "-d", database, "-q", "-t", "-c", query]

def execPsqlDynamicSql(sql):
   '''
   Executes dynamic sql query which is generated by the input

   @sql: input for dynamic query
   '''
   pipe1 = Popen(psqlQuery(sql), stdout = PIPE)
   cmd2 = [PSQL, "-U", "vc", "-d", "VCDB"]
   pipe2 = Popen(cmd2, stdin = pipe1.stdout, stdout = PIPE)
   pipe1.stdout.close()
   pipe2.communicate()
   pipe2.stdout.close()

def preImportScripts(schemaName):
   '''
   VCDB index and constraint drop and create into files.
   When completed drop all indexes and constraints.
   This step is required for faster import.

   @schemaName: vPostgres VCDB schema name
   '''
   # BEGIN: SQL section
   # CREATE index
   sqlCreateIndex =  """
                     SELECT pg_catalog.pg_get_indexdef(i.indexrelid, 0, true) || ';'
                       FROM pg_class c
                       JOIN pg_index i
                         ON c.oid = i.indrelid
                       JOIN pg_class c2
                         ON i.indexrelid = c2.oid
                       JOIN pg_namespace n
                         ON n.oid=c.relnamespace
                            AND nspname = '%s'
                       LEFT JOIN pg_catalog.pg_constraint con
                         ON con.conrelid = i.indrelid
                            AND con.conindid = i.indexrelid
                            AND con.contype IN ('p','u','x')
                      WHERE NOT EXISTS(SELECT 1
                                         FROM pg_constraint
                                        WHERE  conname = c2.relname)
                     """ % (schemaName)

   # CREATE constraint
   sqlCreateConstr = """
                     SELECT 'ALTER TABLE ' || c.relname||
                              ' ADD CONSTRAINT ' || con.conname ||
                                 ' ' || pg_get_constraintdef(con.oid)||';' ||
                                 CASE  WHEN i.indisclustered='t'
                                       THEN ' cluster ' || c.relname|| ' using ' || con.conname || ';'
                                       ELSE ''
                                 END
                       FROM pg_constraint con
                       JOIN pg_class c
                         ON con.conrelid = c.oid
                       JOIN pg_namespace n
                         ON n.oid = c.relnamespace
                       LEFT JOIN pg_index i
                         ON con.conrelid = i.indrelid
                         AND con.conindid = i.indexrelid
                      WHERE n.nspname = '%s'
                      ORDER BY con.contype DESC
                     """ % (schemaName)

   # DROP index
   sqlDropIndex = """
                  SELECT 'DROP INDEX IF EXISTS ' || c.relname || ' CASCADE;'
                    FROM pg_class c
                    LEFT JOIN pg_namespace n
                      ON n.oid = c.relnamespace
                   WHERE c.relkind IN ('i','')
                     AND n.nspname = '%s'
                     AND pg_table_is_visible(c.oid)
                     AND NOT EXISTS(SELECT 1
                                      FROM pg_constraint
                                     WHERE conname = c.relname)
                  """ % (schemaName)

   # DROP constraint
   sqlDropConstr =   """
                     SELECT 'ALTER TABLE ' || relname ||
                              ' DROP CONSTRAINT IF EXISTS ' || conname || ' CASCADE;'
                       FROM pg_constraint con
                       JOIN pg_class c
                         ON con.conrelid = c.oid
                       JOIN pg_namespace n
                         ON n.oid = c.relnamespace
                      WHERE n.nspname = '%s'
                     """ % (schemaName)

   # TRUNCATE table
   sqlTrunc =  """
               SELECT 'TRUNCATE TABLE ' || c.relname || ' CASCADE;'
                 FROM pg_class c
                 JOIN pg_namespace n
                   ON n.oid = c.relnamespace
                WHERE c.relkind = 'r'
                  AND n.nspname = 'vc'
                  AND pg_table_is_visible(c.oid)
               """
   # END: SQL section

   # BEGIN: Prepare scripts section
   # CREATE script for indexes
   with open(CREATE_INDEXES, "w") as f:
      ret = call(psqlQuery(sqlCreateIndex), stdout=f, stderr=fileError)
   print ("Saved Indexes from target DB to file %s." % CREATE_INDEXES)

   # CREATE script for constraints
   with open(CREATE_CONSTRAINTS, "w") as f:
      ret = call(psqlQuery(sqlCreateConstr), stdout=f, stderr=fileError)
   print ("Saved Constraints from target DB to file %s." % CREATE_CONSTRAINTS)
   # END: Prepare scripts section

   # BEGIN: drop VCDB indexes and constraints on destination
   # DROP indexes
   execPsqlDynamicSql(sqlDropIndex)
   print ("Dropped Indexes in target DB.")  
   # DROP constraints
   execPsqlDynamicSql(sqlDropConstr)
   print ("Dropped Constraints in target DB.")  
   # END: drop VCDB indexes and constraints on destination

   # Truncate all tables on destination.
   # This is required for Windows only because
   # we use fresh install scripts to deploy 5.x database.
   # Those fresh install scripts have initialized some catalog tables.
   execPsqlDynamicSql(sqlTrunc)
   print ("Truncated all tables in target DB.") 

def postImportScripts():
   '''
   Recreate indexes and constraints after data import.
   '''
   # CREATE indexes
   ret = call(psqlFile(CREATE_INDEXES), stdout=fileOut, stderr=fileError)
   print ("Recreated Indexes back in target DB from file %s." % CREATE_INDEXES )
   # CREATE constraints
   ret = call(psqlFile(CREATE_CONSTRAINTS), stdout=fileOut, stderr=fileError)
   print ("Recreated Constraints back in target DB from file %s." % CREATE_CONSTRAINTS )

def main():
   parser = argparse.ArgumentParser()
   parser.add_argument('-p',
                       action="store",
                       dest="password",
                       required=True)
   parser.add_argument('-f',
                       action="store",
                       dest="backup_file",
                       required=True)
   results = parser.parse_args()

   print ("Operation not cancellable. Please wait for it to finish...")

   passExists = False
   folderExists = False
   linesCount = 0
   if path.isfile(PG_PASS_FILE):
      passExists = True
      linesCount = sum(1 for l in open(PG_PASS_FILE))

   if not passExists:
      if not os.path.exists(PG_PASS_FOLDER):
         os.makedirs(PG_PASS_FOLDER)
      else:
         folderExists = True

   with open(PG_PASS_FILE, 'a') as f:
      line = "\nlocalhost:5432:VCDB:vc:%s" % (results.password)
      f.write(line)

   global fileOut
   fileOut = open(path.join(CIS_LOG, "restore_out.log"), "a+")
   global fileError
   fileError = open(path.join(CIS_LOG, "restore_err.log"), "a+")

   sql = """
         SELECT nspname
           FROM pg_namespace
          WHERE nspname in ('vc', 'vpx')
         """
   pipe = Popen(psqlQuery(sql), stdout = PIPE)
   schemaName = pipe.communicate()[0].strip()
   pipe.stdout.close()

   if sys.version_info[0] > 2:
      schemaName=schemaName.decode()

   fileOut.write("Running pre-import scripts...\n")
   preImportScripts(schemaName)
   fileOut.write("Pre-import step completed.\n")

   cmd = [PG_RESTORE, "-a", "-Fc", "--disable-triggers", "-U", "vc", "-d", "VCDB", results.backup_file]
   ret = call(cmd, stdout=fileOut, stderr=fileError)

   fileOut.write("Running post-import scripts...\n")
   postImportScripts()
   fileOut.write("Post-import step completed.\n")

   fileOut.close()
   fileError.close()

   if passExists:
      n = sum(1 for line in open(PG_PASS_FILE))
      if linesCount == n:
         return
      toDelete = n - linesCount
      with open(PG_PASS_FILE) as f:
         lines = f.readlines()
      with open(PG_PASS_FILE,"w") as f:
         f.writelines([item for item in lines[:-toDelete]])
   else:
      if folderExists:
         os.remove(PG_PASS_FILE)
      else:
         shutil.rmtree(PG_PASS_FOLDER)

   print ("Restore completed successfully.")

if __name__ == "__main__":
   main()