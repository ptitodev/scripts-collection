for filename in ./*; do mv "./$filename" "./$(echo $filename | sed -e 's/\-template//g')";  done