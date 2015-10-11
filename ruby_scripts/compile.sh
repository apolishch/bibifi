#!/bin/bash

output_dir="../build"

rm -rf $output_dir/*

cat common.rb validations.rb atm.rb > $output_dir/atm
cat common.rb validations.rb operations.rb bank.rb > $output_dir/bank

chmod +x $output_dir/*
