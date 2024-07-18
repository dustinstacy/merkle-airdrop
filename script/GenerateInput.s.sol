// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { console } from "forge-std/console.sol";

/// @title GenerateInput
/// @author Ciara Nightingale
/// @notice A contract to generate input JSON for a script execution
contract GenerateInput is Script {
    /// @dev The amount value for each entry in wei
    uint256 private constant AMOUNT = 25 * 1e18;

    /// @dev The path where the generated JSON will be saved
    string private constant INPUT_PATH = "/script/target/input.json";

    /// @dev Number of entries in the whitelist
    uint256 count;
    /// @dev Types of data in each whitelist entry
    string[] types = new string[](2);
    /// @dev List of whitelisted addresses
    string[] whitelist = new string[](4);

    /// @notice Executes the script to generate JSON
    function run() public {
        types[0] = "address";
        types[1] = "uint";
        whitelist[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        count = whitelist.length;
        string memory input = _createJSON();
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    /// @notice Internal function to create JSON string based on whitelist entries
    /// @return json The generated JSON string
    function _createJSON() internal view returns (string memory json) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(AMOUNT); // convert amount to string
        json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }
        json = string.concat(json, "} }");
        return json;
    }
}
