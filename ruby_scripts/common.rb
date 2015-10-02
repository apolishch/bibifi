Signal.trap('INT')  { exit 0 } # Trap ^C      == "INT"
Signal.trap('TERM') { exit 0 } # Trap `Kill ` == "TERM"

EXIT_CODE = 255

# All other errors, specified throughout this document or
# unrecoverable errors not explicitly discussed, should prompt the
# program to exit with return code 255
# >>>> it's from RAILS 
# >>>> http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html
#rescue_from 'SystemCallError' do |e|
	#debug e.class.name.to_s
    #exit(EXIT_CODE)
#end
