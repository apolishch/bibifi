#!/bin/bash
cd "/root/install/tests/"

./run_test.py core/core1.json
./run_test.py core/core2.json
./run_test.py core/core3.json
./run_test.py core/core4.json
./run_test.py core/core5.json
./run_test.py core/core6.json

./run_test.py core/createaccount.json
./run_test.py core/deposit.json
./run_test.py core/withdraw.json
./run_test.py core/getbalance.json

./run_test.py performance/1.json
./run_test.py performance/2.json
./run_test.py performance/3.json
./run_test.py performance/4.json
./run_test.py performance/5.json
./run_test.py performance/6.json
./run_test.py performance/7.json
./run_test.py performance/8.json
./run_test.py performance/9.json
./run_test.py performance/10.json

./run_test.py core/invalid1.json
./run_test.py core/timeout1.json
