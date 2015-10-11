#!/bin/bash

output_dir="../build"

rm -rf $output_dir/atm $output_dir/bank $output_dir/*.card $output_dir/*.auth

cat common.rb validations.rb atm.rb > $output_dir/atm
cat common.rb validations.rb operations.rb bank.rb > $output_dir/bank

chmod +x $output_dir/atm
chmod +x $output_dir/bank
