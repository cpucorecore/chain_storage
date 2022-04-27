const fs = require('fs');
const Web3Utils = require('web3-utils');
const {checkUndefined} = require('./util');

const Setting = artifacts.require("Setting");
const Resolver = artifacts.require("Resolver");

const FileStorage = artifacts.require("FileStorage");
const File = artifacts.require("File");
const UserStorage = artifacts.require("UserStorage");
const User = artifacts.require("User");
const NodeStorage = artifacts.require("NodeStorage");
const Node = artifacts.require("Node");
const TaskStorage = artifacts.require("TaskStorage");
const Task = artifacts.require("Task");

module.exports = function(deployer) {
    let contracts = {};
    let contractAddrs = {};

    deployer
        .then(function() {
            return deployer.deploy(Setting);
        })

        // Setting deploy
        .then(setting => {
            checkUndefined('setting', setting);
            contracts.setting = setting;
            contractAddrs.setting = setting.address;
            return deployer.deploy(Resolver);
        })
        .then(resolver => {
            checkUndefined('resolver', resolver);
            contracts.resolver = resolver;
            contractAddrs.resolver = resolver.address;
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Setting'), contracts.setting.address);
        })

        // File and FileStorage deploy
        .then((receipt) => {
            console.log('resolver.setAddress(Setting) receipts: ', receipt);
            return deployer.deploy(File, contracts.resolver.address);
        })
        .then((file) => {
            checkUndefined('file', file);
            contracts.file = file;
            contractAddrs.file = file.address;
            return deployer.deploy(FileStorage, contracts.file.address);
        })
        .then((fileStorage) => {
            checkUndefined('fileStorage', contracts.settingStorage);
            contracts.fileStorage = fileStorage;
            contractAddrs.fileStorage = fileStorage.address;
            return contracts.file.setStorage(contracts.settingStorage.address);
        })
        .then((receipt) => {
            console.log('file.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('File'), contracts.file.address);
        })

        // User and UserStorage deploy
        .then((receipt) => {
            console.log('resolver.setAddress(File) receipts: ', receipt);
            return deployer.deploy(User, contracts.resolver.address);
        })
        .then((user) => {
            checkUndefined('user', user);
            contracts.user = user;
            contractAddrs.user = user.address;
            return deployer.deploy(UserStorage, contracts.user.address);
        })
        .then((userStorage) => {
            checkUndefined('userStorage', contracts.userStorage);
            contracts.userStorage = userStorage;
            contractAddrs.userStorage = userStorage.address;
            return contracts.user.setStorage(contracts.userStorage.address);
        })
        .then((receipt) => {
            console.log('user.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('User'), contracts.user.address);
        })

        // Node and NodeStorage deploy
        .then((receipt) => {
            console.log('resolver.setAddress(User) receipts: ', receipt);
            return deployer.deploy(Node, contracts.resolver.address);
        })
        .then((node) => {
            checkUndefined('node', node);
            contracts.node = node;
            contractAddrs.node = node.address;
            return deployer.deploy(NodeStorage, contracts.node.address);
        })
        .then((nodeStorage) => {
            checkUndefined('nodeStorage', contracts.nodeStorage);
            contracts.nodeStorage = nodeStorage;
            contractAddrs.nodeStorage = nodeStorage.address;
            return contracts.node.setStorage(contracts.nodeStorage.address);
        })
        .then((receipt) => {
            console.log('node.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Node'), contracts.node.address);
        })

        // Task and TaskStorage deploy
        .then((receipt) => {
            console.log('resolver.setAddress(Node) receipts: ', receipt);
            return deployer.deploy(Task, contracts.resolver.address);
        })
        .then((task) => {
            checkUndefined('task', task);
            contracts.task = task;
            contractAddrs.task = task.address;
            return deployer.deploy(TaskStorage, contracts.task.address);
        })
        .then((taskStorage) => {
            checkUndefined('taskStorage', contracts.taskStorage);
            contracts.taskStorage = taskStorage;
            contractAddrs.taskStorage = taskStorage.address;
            return contracts.task.setStorage(contracts.taskStorage.address);
        })
        .then((receipt) => {
            console.log('task.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Task'), contracts.task.address);
        })

        // refreshCache
        .then((receipt) => {
            console.log('resolver.setAddress(Task) receipts: ', receipt);
            return contracts.file.refreshCache();
        })
        .then((receipt) => {
            console.log('file.refreshCache receipt: ', receipt);
            return contracts.user.refreshCache();
        })
        .then((receipt) => {
            console.log('user.refreshCache receipt: ', receipt);
            return contracts.node.refreshCache();
        })
        .then((receipt) => {
            console.log('node.refreshCache receipt: ', receipt);
            return contracts.task.refreshCache();
        })

        // save contract addresses
        .then((receipt) => {
            console.log('task.refreshCache receipt: ', receipt);
            console.log("contracts deployment finished\n\n");
            const addrs = JSON.stringify(contractAddrs, null, '\t');
            fs.writeFile('contractAddrs.json', addrs, (err) => {
                if (err) {
                    throw err;
                }
                console.log("contractAddrs saved");
            });
        });
};
