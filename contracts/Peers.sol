// Copyright 2022 Jonathan Herbst
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


enum PeerRole { DISABLED, PEER, ADMIN }

struct Peer {
    address addr;
    PeerRole role;
    bytes32 properties;
}

library Peers {

    // Get the peer from the map.  Return zeroed peer if the address doesn't exist.
    function get(PeerMap storage map, address addr) internal view returns(Peer memory) {
        uint index = map._indexes[addr];
        Peer memory peer;
        if(index != 0) {
            peer = map._values[index - 1];
        }
        return peer;
    }

    // Check that the map contains addr.
    function contains(PeerMap storage map, address addr) internal view returns(bool) {
        return map._indexes[addr] != 0;
    }

    // Set the peer in the map, overwrites if the peer already exists.  Return true if the peer doesn't exist, false if overwritten.
    function set(PeerMap storage map, Peer memory peer) internal returns(bool) {
        if(map._indexes[peer.addr] != 0) {
            map._values[map._indexes[peer.addr]] = peer;
            return false;
        } else {
            map._values.push(peer);
            map._indexes[peer.addr] = map._values.length;
            return true;
        }
    }

    // Remove the peer from the maps
    function remove(PeerMap storage map, address addr) internal returns(bool) {
        uint index = map._indexes[addr];
        if(index != 0) {
            uint endIndex = map._values.length;
            if(endIndex != index) {
                _movePeer(map, endIndex, index);
            }
            map._values.pop();
            map._indexes[addr] = 0;
            return true;
        }
        return false;
    }

    // Get an array of all peers stored in the map.
    function values(PeerMap storage map) internal view returns (Peer[] memory) {
        return map._values;
    }

    function _movePeer(PeerMap storage map, uint from, uint to) private {
        Peer memory peer = map._values[from - 1];
        map._values[to - 1] = peer;
        map._indexes[peer.addr] = to;
    }

    struct PeerMap {
        Peer[] _values;
        mapping(address => uint) _indexes;
    }
}