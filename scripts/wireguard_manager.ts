// Copyright 2022 Jonathan Herbst
// 
// Application of the peer network for wireguard networks

import { ethers } from "ethers";

const USER_PRIVATE_KEY = ""

async function main() {
    const Lock = await ethers.getContractFactory("Lock");
}

class Device {
    ipAddresses: string[] = [];
}

class WireguardNetwork {
    _network_address: string
    _contract: ethers.Contract
    _device_changed_callbacks: ((sender: string, device: Device) => void)[] = []
    _request_endpoints_callbacks: ((sender: string) => void)[] = []
    _respond_endpoints_callbacks: ((sender: string, payload: string) => void)[] = []

    static create(signer: ethers.Signer, network_address: string, )

    constructor(signer: ethers.Signer, network_address: string) {
        const CONTRACT_ADDRESS = ""
        const CONTRACT_ABI = new ethers.utils.Interface([])

        this._network_address = network_address
        this._contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
    }

    on_device_changed(fn: (sender: string, device: Device) => void) {
        
    }

}



async function make_wireguard_config() {

}