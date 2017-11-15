require_relative "IDH_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

@sl.h1 'Preliminary actions'

###

@sot.txt 'Set wallets'
@sot.own :set_wallet, @wallet_account
@sot.exp :wallet,     @sot.strip0x(@wallet_account)
@sot.own :set_admin_wallet, @admin_account
@sot.exp :admin_wallet,     @sot.strip0x(@admin_account)
@sot.do

###############################################################################

@sl.h1 'Before presale'

###

@sot.txt 'Mint marketing: ok'
@sot.own :mint_marketing, @a[10], 50 * @E6 * @E6
@sot.own :mint_marketing, @a[11], 30 * @E6 * @E6
@sot.own :mint_marketing, @a[12],       1  * @E6 # over the limit
@sot.exp :balance_of, @a[10], 50 * @E6 * @E6, 50 * @E6 * @E6
@sot.exp :balance_of, @a[11], 30 * @E6 * @E6, 30 * @E6 * @E6
@sot.exp :balance_of, @a[12], 0, 0
@sot.exp :locked, @a[10], true
@sot.exp :locked, @a[11], true
@sot.exp :locked, @a[12], false
@sot.do

###

@sot.txt 'Early contribution: fails'
@sot.snd @k[1], 10 # this contribution gets rejected
@sot.exp :balance_of, @a[1], 0, 0
@sot.do


###############################################################################

@sl.h1 'Presale'

epoch = @sot.var :date_presale_start
jump_to(epoch, 'presale')

###

@sot.txt 'Some presale contributions'
@sot.snd @k[1], 100
@sot.snd @k[2], 0.49  # fails - too little
@sot.snd @k[3], 50000 # fails - too much
@sot.snd @k[10], 50
@sot.exp :balance_of, @a[1], 100 * 4480 * @E6, 100 * 4480 * @E6
@sot.exp :balance_of, @a[2], 0, 0
@sot.exp :balance_of, @a[3], 0, 0
@sot.exp :balance_of, @a[10], nil, 50 * 4480 * @E6
@sot.do

###

###############################################################################

@sl.h1 'After presale'

epoch = @sot.var :date_presale_end
jump_to(epoch, 'after presale')

###

@sot.txt 'No more contributions accepted after presale end'
@sot.snd @k[6], 100
@sot.exp :balance_of, @a[6], 0,  0
@sot.do

### 

@sot.txt 'Remove lock'
@sot.add :remove_lock, @admin_key, @a[1]
@sot.exp :locked, @a[1], false
@sot.do

###

@sot.txt 'Token transfer attempt fails even if unlocked'
@sot.add :transfer, @k[1], @a[19], 100 * @E6
@sot.exp :balance_of,  @a[1], nil, 0
@sot.exp :balance_of,  @a[19],  0, 0
@sot.do

###

@sot.txt 'clawback/reclaim/airdop all fail'
@sot.own :owner_clawback
@sot.add :reclaim_funds, @k[1]
@sot.add :claim_airdrop, @k[1]
@sot.exp :get_balance, @contract_address, nil, 0
@sot.exp :get_balance, @a[1], nil, 0
@sot.exp :balance_of,  @a[1], nil, 0
@sot.do


###############################################################################

@sl.h1 'ICO - week 1'

epoch = @sot.var :date_ico_start
jump_to(epoch, 'ico week 1')

###

@sot.txt 'ICO contribution week 1'
@sot.snd @k[2], 100
@sot.exp :balance_of,  @a[2], 100 * 3840 * @E6,  100 * 3840 * @E6
@sot.do

###############################################################################

@sl.h1 'ICO - week 2'

epoch = @sot.var :date_ico_start
jump_to(epoch + 7*24*3600, 'ico week 2')

###

@sot.txt 'ICO contribution week 2'
@sot.snd @k[3], 100
@sot.exp :balance_of,  @a[3], nil,  100 * 3520 * @E6
@sot.exp :get_balance, @contract_address, nil, 100 * @E18
@sot.do

###############################################################################

@sl.h1 'ICO - week 3'

epoch = @sot.var :date_ico_start
jump_to(epoch + 14*24*3600, 'ico week 3')

###

@sot.txt 'ICO contribution week 3'
@sot.snd @k[1], 10
@sot.snd @k[2], 20
@sot.exp :balance_of,  @a[1], nil,  10 * 3200 * @E6
@sot.exp :balance_of,  @a[2], nil,  20 * 3200 * @E6
@sot.exp :locked, @a[1], true
@sot.exp :locked, @a[2], true
@sot.do

###############################################################################

@sl.h1 'After ICO (UNSUCCESSFUL)'

epoch = @sot.var :date_ico_end
jump_to(epoch, 'after ico')

###

@sot.txt 'Token transfer attempt fails '
@sot.add :remove_lock, @admin_key, @a[1]
@sot.add :transfer, @k[1], @a[19], 100 * @E6
@sot.exp :locked, @a[1], false
@sot.exp :balance_of,  @a[1], nil, 0
@sot.exp :balance_of,  @a[19],  0, 0
@sot.do

###

@sot.txt 'Claim airdrop not possible'
@sot.add :claim_airdrop, @k[10]
@sot.exp :balance_of, @a[10], nil, 0
@sot.do

###

@sot.txt 'Clawback not possible'
@sot.own :owner_clawback
@sot.exp :get_balance, @contract_address, nil, 0
@sot.do

###

@sot.txt 'Reclaim funds - ok'
@sot.add :reclaim_funds, @k[1]
@sot.exp :balance_of, @a[1], nil, -480000 * @E6
@sot.exp :get_balance, @a[1], nil, 110 * @E18
@sot.do



###############################################################################

@sl.h1 'After 2-day cooldown period'

epoch = @sot.var :date_ico_end
jump_to(epoch + 2*24*3600, 'after cooldown')

###


###############################################################################

@sl.h1 'After 2-day cooldown period'

epoch = @sot.var :date_ico_end
jump_to(epoch + 92*24*3600, 'after cooldown')

###

###

@sot.txt 'Clawback ok'
@sot.own :owner_clawback
@sot.exp :get_balance, @wallet_account, nil, 270 * @E18
@sot.exp :get_balance, @contract_address, nil, -270 * @E18
@sot.do



###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"

