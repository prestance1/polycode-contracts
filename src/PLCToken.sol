pragma solidity ^0.8.13;
import {ERC20} from "solmate/tokens/ERC20.sol";

contract PLC is ERC20 {
    constructor() ERC20("PolyCode Token", "PLC", 18) {
        _mint(msg.sender, 1_000_000*10**18);
    }
}