pragma solidity ^0.8.13;

//import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC20Burnable} from "openzeppelin-contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract PLC is ERC20Burnable {
    constructor() ERC20("PolyCode Token", "PLC") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}
