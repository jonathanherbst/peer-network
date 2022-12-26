// Copyright 2022 Jonathan Herbst
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Peers.sol";

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract PeerNetwork {
    using ECDSA for bytes32;
    using Peers for Peers.PeerMap;

    bytes public properties;
    Peers.PeerMap peers;

    constructor(bytes memory _properties, bytes32 senderProperties) {
        properties = _properties;
        _setPeer(msg.sender, PeerRole.ADMIN, senderProperties);
    }

    function setProperties(bytes memory _properties) public onlyAdmin() {
        properties = _properties;

        emit PropertiesUpdated(_properties);
    }

    function setPeerRole(address addr, PeerRole role) public onlyAdmin() {
        _setPeerRole(addr, role);
    }

    function setPeer(address addr, PeerRole role, bytes32 parameters) public onlyAdmin() {
        _setPeer(addr, role, parameters);
    }

    function setPeerProperties(bytes32 _properties) public onlyPeer() {
        _setPeerProperties(msg.sender, _properties);
    }

    function setPeerPropertiesFor(address addr, bytes32 _properties, bytes memory signature) public onlyPeer() {
        bytes32 unsignedHash = getPeerPropertiesHash(addr, _properties);
        bytes32 signedHash = unsignedHash.toEthSignedMessageHash();
        address signer = signedHash.recover(signature);

        if(signer == addr) {
            _setPeerProperties(addr, _properties);
        }
    }

    function getPeerPropertiesHash(address addr, bytes32 _properties) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(addr, _properties));
    }

    function getPeers() external view returns(Peer[] memory) {
        return peers.values();
    }

    function sendMessage(address to, bytes memory message) public {
        emit Message(to, msg.sender, message);
    }

    modifier onlyAdmin() {
        require(_getPeerRole(msg.sender) == PeerRole.ADMIN);
        _;
    }

    modifier onlyPeer() {
        require(_getPeerRole(msg.sender) != PeerRole.DISABLED);
        _;
    }

    function _setPeer(address addr, PeerRole role, bytes32 _properties) internal {
        Peer memory peer = Peer(addr, role, _properties);
        peers.set(peer);

        emit PeerPropertiesUpdated(addr, _properties);
    }

    function _setPeerRole(address addr, PeerRole role) internal {
        Peer memory peer = peers.get(addr);
        peer.addr = addr;
        peer.role = role;
        peers.set(peer);
    }

    function _setPeerProperties(address addr, bytes32 _properties) internal {
        Peer memory peer = peers.get(addr);
        peer.addr = addr;
        peer.properties = _properties;
        peers.set(peer);

        emit PeerPropertiesUpdated(addr, _properties);
    }

    function _getPeerRole(address peer) internal view returns(PeerRole) {
        return PeerRole(peers.get(peer).role);
    }

    event PropertiesUpdated(bytes properties);
    event PeerPropertiesUpdated(address addr, bytes32 properties);
    event Message(address to, address from, bytes data);
}