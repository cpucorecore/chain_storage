const Web3Utils = require('web3-utils');
const {checkUndefined} = require('./util');

const Resolver = artifacts.require("Resolver");
const Node = artifacts.require("Node");
const Task = artifacts.require("Task");

module.exports = function(deployer) {
    let contracts = {};
    let contractAddrs = {};

    deployer
        .then(() => {
            return deployer.deploy(Resolver, {gas:1000000});
        })
        .then(resolver => {
            checkUndefined('resolver', resolver);
            contracts.resolver = resolver;
            contractAddrs.resolver = resolver.address;
            return deployer.deploy(Node, contracts.resolver.address, {gas:190000000});
        })
        .then(node => {
            checkUndefined('node', node);
        })
}