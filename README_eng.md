
﻿

# token-transfer-using-orzclize

The smart contract for token transfer using [Oraclize](https://github.com/oraclize/ethereum-api).
There are one token contract and four youtube counter contract in this repo.

- `ERC20.sol`   The token contract. Using ERC20 Contract from [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-solidity).
- `youtube_viewcount.sol` Ether paying contract by youtube viewcount.
- `timer_youtube_viewcount.sol` Ether paying contract by youtube viewcount with timer. Calibrate viewcount between two set time and send ether of viewcount between the time.
- `token_youtube_viewcount.sol` Token paying contract by youtube viewcount.
- `token_timer_youtube_viewcount.sol` Token paying contract by youtube viewcount with timer. Calibrate viewcount between two set time and send token of viewcount between the time.


## Usage
You can deploy smart contract for calibrate youtube viewcount and send ether/token.
It can use for paying method of youtube video ad or MCN business.


------------

### Common application

#### about mapping
`index`calls `idx` variable based on `x`th transaction of receiver's address.
`transaction_rec` mapping calls `transaction` structure based on  `idx` variable.

For example, if there are five transactions to  `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`, the address has five `idx_num` through one to five. You can know the `idx` variable which shows the number of transaction in the whole transaction using `index [#1][#2]`. When you input receiver's address in #1 and number of transaction order you wish to know in #2, it shows `idx` variable.
Using `idx` calls detailed transaction records.

`transaction` structure has below informations.

- `blocknum` Block number that transaction admitted.
- `blocktime` Block time that transaction admitted.
- `viewrate` Ether/token rate per view.
- `receiver` Address of receive ether/token.
- `amount_of_transfer` Total amount of transferred ether/token.
- `targetaddress` Youtube URL that based on this contract.

#### ※ You need some ether in the contract address to using Oraclize more than two times.

------
----


## 1.  Ether paying contract depend on youtube viewcount
Filename :` youtube_viewcount.sol`

You can set target youtube URL, address of ether receiver and rate of ether per view.
  
  --------
#### Contract name : `YoutubeCounter`
#### *How to use*

`YoutubeCounter` Constructor
- Set msg.sender as owner.

`YoutubeViews` Youtube video informations
- You can set the target youtube video URL, address of receiver and rate of pay per view using parameters.
- _videoaddress : target youtube URL(string)
- _beneficiary : address of receiver(address)
 - _PayPerView : rate of ether pay per view(uint)

`ethertransfer` Ether transfer module
- You can run and transfer by function YoutubeViews.(ether transfer, unit is wei)
- Input transaction information into `transaction` struct.
  
 `refund` Refund module
 - Refund ether in the contract to owner.


----
----
## 2. Ether paying contract depend on youtube viewcount with timer

Filename : `timer_youtube_viewcount.sol`

Calibrating the performance(viewcount) between two time points which are setted timepoint(A) and timepoint of declared time after(B). Transfer ether depends on the performance.
In this document, explain the additional parts of 1.  Ether paying contract depend on youtube viewcount because the basic structures are same.

#### *How to use*
`YoutubeView_setup` for set youtube video URL, address of receiver and rate of pay per view. It set the timepoint A.
After run `YoutubeView_setup`, run `YoutubeView_timer`. If you want to change the timer, you can correct the code below.

    oraclizeID_2 = oraclize_query(120, "URL", query_2);

Correct `120` to the time you want. `120` means 120 sec, which is 3 minutes. In this code, the function calls the viewcount after 3 minutes of the function executed. The standards of time are below.

- 1 minute : 60
- 1 day : 86400
- 1 week(7days) : 604800
- 1 month(4weeks) : 2419200

In this method, `viewcounter` and `amount_of_transfer` in struct `transaction` becomes `setted timepoint(A) - timer called timepoint(B)`.

----
----


## 3. Token paying contract depend on youtube viewcount
Filename : `ERC20.sol`  and  `seperated_youtube_viewcount.sol`

Contract for transfer token not ether. Make and control token using `ERC20.sol` and transfer token by youtube viewcount using `seperated_youtube_viewcount.sol`

#### ※ You need some ether in the youtube viewcount contract address to using Oraclize.
------------
#### Filename : `ERC20.sol`
#### Contract name : `SimpleToken`
#### *How to use*

**`constructor`  Constructor**
- Deploy token as number of INITIAL_SUPPLY.
- Set contract deployer as owner.
- Include contract deployer in `addControllers`.

**`addControllers`** Token transfer authorization
- Token cannot transferred if the contract or user is not in `controller`.
- Input address to give authorize of token control in `controller`.

**`tokentransfer` Token transfer from the contract**
- Transfer token from the contract.
- Send token to `_to` amount of `_value`.

**`transferFrom` : Token transfer from A to B**
- Transfer token from address A to address B.
- Send token from `_from` to `_to` amount of `_value`.

**`transfer` : Token transfer from msg.sender**
- Transfer token from msg.sender.
- Send token to `_to` amount of `_value`.

#### *Parameters*
- `name` : Name of the token
- `symbol` : Abbreviation of the token
- `decimals` : Decimal unit of the token
- `INITIAL_SUPPLY` : Initial volume of the token(value * (10^(decimals))
- `owner` : Owner of the contract
- `allowedControllers` : Account can control the token

------------
#### Filename : `token_youtube_count.sol`
#### Contract name : `YoutubeViews`
#### *How to use*


`YoutubeViews` Youtube video informations
- You can set the target youtube video URL, address of receiver and rate of pay per view using parameters.
- _videoaddress : target youtube URL(string)
- _beneficiary : address of receiver(address)
 - _PayPerView : rate of token pay per view(uint)

`tokentransfer` Token transfer module
- You can run and transfer token by function YoutubeViews.
- Input transaction information into `transaction` struct.

※ It should input address of token contract deployed by  `ERC20.sol` directly like below.

    address public tokenaddress = 0xee9c3a618d8786c6343fc079a75462839b3a673b;

In the code, you should input contract address of token after `=`. Also, `YoutubeView` contract should allowed as `controller` in `ERC20` contract using `addController` function.   

----
----

## 4. Token paying contract depend on youtube viewcount with timer

#### Filename : `token_timer_youtube_count.sol`

Calibrating the performance(viewcount) between two time points which are setted timepoint(A) and timepoint of declared time after(B). Transfer token depends on the performance.
In this document, explain the additional parts of 3.  Token paying contract depend on youtube viewcount because the basic structures are same.

#### *How to use*
`YoutubeView_setup` for set youtube video URL, address of receiver and rate of pay per view. It set the timepoint A.
After run `YoutubeView_setup`, run `YoutubeView_timer`. If you want to change the timer, you can correct the code below.

    oraclizeID_2 = oraclize_query(120, "URL", query_2);

Correct `120` to the time you want. `120` means 120 sec, which is 3 minutes. In this code, the function calls the viewcount after 3 minutes of the function executed. The standards of time are below.

- 1 minute : 60
- 1 day : 86400
- 1 week(7days) : 604800
- 1 month(4weeks) : 2419200

In this method, `viewcounter` and `amount_of_transfer` in struct `transaction` becomes `setted timepoint(A) - timer called timepoint(B)`.
