require_relative "IDH_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

###

@sot.txt 'Approve & transferFrom : ok'
@sot.add :approve, @k[1], @a[2], 10 * @E6

@sot.add :transfer_from, @k[2], @a[1], @a[7], 4 * @E6
@sot.add :transfer_from, @k[2], @a[1], @a[8], 4 * @E6
@sot.add :transfer_from, @k[2], @a[1], @a[9], 4 * @E6 # not enough

@sot.exp :balance_of,  @a[2], nil,  0
@sot.exp :balance_of,  @a[1], nil,  - 8 * @E6
@sot.exp :balance_of,  @a[7], nil,  4 * @E6
@sot.exp :balance_of,  @a[8], nil,  4 * @E6
@sot.exp :balance_of,  @a[9], nil,  0
@sot.do

###

@sot.txt 'transferFrom : to locked account'

@sot.add :transfer_from, @k[2], @a[1], @a[6], 2 * @E6 # enough but 6 is locked
@sot.exp :balance_of,  @a[2], nil,  0
@sot.exp :balance_of,  @a[1], nil,  0
@sot.exp :balance_of,  @a[6], nil,  0
@sot.do

@sot.txt 'transferFrom : remaining 2 to unlocked account'

@sot.add :transfer_from, @k[2], @a[1], @a[9], 2 * @E6
@sot.exp :balance_of,  @a[2], nil,  0
@sot.exp :balance_of,  @a[1], nil,  -2 * @E6
@sot.exp :balance_of,  @a[9], nil,  2 * @E6
@sot.do



###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"

