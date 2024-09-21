!#/bin/sh

# Repeat 10 times
for i in {1..10}
do
    echo $i
    ./a.out
    mv image.ppm stack/$i.ppm
done

poetry run python stack.py
echo Finished!
