# bibifi

```sh
# Generate self-contained files
cd ruby_scripts
./compile.sh

# Play with atm and bank
cd ../build
./bank &
./atm -a bob -n 10.00
./atm -a bob -d 15.00
./atm -a bob -w 5.00
./atm -a bob -g
./atm -a alice -n 15.00
./atm -a alice -c bob.card -g
echo $? # 255
```

Requirement: ruby 2.1.2p95 or higher