#!/bin/bash

output_dir="self-contained"

rm -rf $output_dir/*

cat common.rb validations.rb atm > $output_dir/atm
cat common.rb validations.rb operations.rb bank > $output_dir/bank

awk '!/require_relative/' $output_dir/atm > temp && mv temp $output_dir/atm
awk '!/require_relative/' $output_dir/bank > temp && mv temp $output_dir/bank

chmod +x $output_dir/*
