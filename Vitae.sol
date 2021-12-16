// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
//pragma solidity ^0.5.13;

/**
 * @title Vitae
 * @dev Contract for grants & NFTs
 */

 contract Vitae {

    address public owner;

    struct Project {
        
        uint id;
        string name;
        string role;
        uint16 category;
        uint16 [] skills;
        uint8 experience;
        uint funding;
        uint dateInitiated;
        uint dateCompleted;

        address client;
        address recipient;

        bool active;
        
    }
    

    mapping(uint=>Project) Projects; // ID to projects
    mapping(address=>uint[]) ClientProjects; // Client Address to IDs
    mapping(address=>uint[]) RecipientProjects; // Client Address to IDs


    constructor() {
        owner = msg.sender;
    }


    function initiateProject(string memory _name, string memory _role, uint16 _category, uint8 _experience, address payable _recipient) public payable{

        require(msg.sender != _recipient, "You cannot be the recipient of your own project.");

        uint _id = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _name)));

        Projects[_id].name = _name;
        Projects[_id].role = _role;
        Projects[_id].category = _category;
        Projects[_id].experience = _experience;
        Projects[_id].recipient = _recipient;

        ClientProjects[msg.sender].push(_id);
        RecipientProjects[_recipient].push(_id);

        Projects[_id].funding = msg.value;

        Projects[_id].client = msg.sender;
        Projects[_id].active = true;
        Projects[_id].dateInitiated = block.timestamp;


    }

    function addFunds(uint _id) public payable{
        Projects[_id].funding += msg.value;
    }


    function initiatePayout(uint _id, bool _completed) public restricted(_id) {
        if (_completed){
            Projects[_id].dateCompleted = block.timestamp;
        }
        address payable payee = payable(Projects[_id].recipient);
        payee.transfer(Projects[_id].funding);
    }


    function designateRecipient(uint _id, address _recipient)  public restricted(_id) {
        Projects[_id].recipient = _recipient;
    }


    function cancelContract(uint _id) public restricted(_id) {
        Projects[_id].active = false;
        address payable client = payable(Projects[_id].client);
        client.transfer(Projects[_id].funding);
    }


    //Modifiers
    modifier restricted(uint _id) {
        require(msg.sender == Projects[_id].client, "You are not the client.");
        _;
    }


    // PROJECT VIEW

    function fetchClientProjects(address _client) public view returns (uint[] memory) {
        return ClientProjects[_client];
    }
    function fetchRecipientProjects(address _recipient) public view returns (uint[] memory) {
        return RecipientProjects[_recipient];
    }
    function viewProjectBalance(uint _id) public view returns  (uint) {
        return Projects[_id].funding;
    }

    // CONTRACT VIEW

    function viewBalance() public view returns(uint) {
        return address(this).balance;
    }

 }