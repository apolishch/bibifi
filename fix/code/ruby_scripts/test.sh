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

./run_test.py performance/performance1.json
./run_test.py performance/performance2.json
./run_test.py performance/performance3.json
./run_test.py performance/performance4.json
./run_test.py performance/performance5.json
./run_test.py performance/performance6.json
./run_test.py performance/performance7.json
./run_test.py performance/performance8.json
./run_test.py performance/performance9.json
./run_test.py performance/performance10.json

./run_test.py core/invalid1.json
./run_test.py core/timeout1.json

./run_test.py extended-tests/02-nonameaccount.json
./run_test.py extended-tests/help.json

