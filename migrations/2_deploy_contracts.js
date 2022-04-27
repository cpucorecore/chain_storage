const fs = require('fs');
const Web3Utils = require('web3-utils');
const {checkUndefined} = require('./util');

const Resolver = artifacts.require("Resolver");

const FileStorage = artifacts.require("FileStorage");
const File = artifacts.require("File");

module.exports = function(deployer, network, accounts) {
    let contracts = {};
    let contractAddrs = {};
    let owner = accounts[0];

    deployer
        .then(function() {
            return deployer.deploy(Resolver);
        })
        .then((resolver) => {
            checkUndefined('resolver', resolver);
            contracts.resolver = resolver;
            contractAddrs.resolver = resolver.address;
            return deployer.deploy(File, contracts.resolver.address);
        })
        .then((file) => {
            checkUndefined('file', file);
            contracts.file = file;
            contractAddrs.file = file.address;
            return deployer.deploy(FileStorage, contracts.file.address);
        })
        .then((fileStorage) => {
            contracts.fileStorage = fileStorage;
            checkUndefined('fileStorage', contracts.fileStorage);
            contractAddrs.fileStorage = fileStorage.address;
            return contracts.file.setStorage(contracts.fileStorage.address);
        })
        .then((receipt) => {
            console.log('file.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('File'), contracts.file.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(File) receipts: ', receipt);
            console.log("contracts deployment finished\n\n");
            const addrs = JSON.stringify(contractAddrs, null, '\t');
            fs.writeFile('commonContractAddrs.json', addrs, (err) => {
                if (err) {
                    throw err;
                }
                console.log("commonContractAddrs saved");
            });
        });
};
