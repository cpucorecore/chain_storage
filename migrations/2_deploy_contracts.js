const fs = require('fs');
const Web3Utils = require('web3-utils');
const {checkUndefined} = require('./util');

const Resolver = artifacts.require("Resolver");
const Setting = artifacts.require("Setting");
const SettingStorage = artifacts.require("SettingStorage");
const FileStorage = artifacts.require("FileStorage");
const File = artifacts.require("File");
const MonitorStorage = artifacts.require("MonitorStorage");
const Monitor = artifacts.require("Monitor");
const UserStorage = artifacts.require("UserStorage");
const User = artifacts.require("User");
const NodeStorage = artifacts.require("NodeStorage");
const Node = artifacts.require("Node");
const TaskStorage = artifacts.require("TaskStorage");
const Task = artifacts.require("Task");
const ChainStorage = artifacts.require("ChainStorage");
const NodeSelectorForTest = artifacts.require("NodeSelectorForTest");

module.exports = function(deployer, _, accounts) {
    let contracts = {};
    let contractAddrs = {};
    const adminAccount = accounts[0];

    deployer
        .then(() => {
            return deployer.deploy(Resolver);
        })
        .then(resolver => {
            checkUndefined('resolver', resolver);
            contracts.resolver = resolver;
            contractAddrs.resolver = resolver.address;
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Admin'), adminAccount);
        })
        .then(receipt => {
            console.log('resolver.setAddress(Admin) receipts: ', receipt);
            return deployer.deploy(Setting);
        })
        .then(setting => {
            checkUndefined('setting', setting);
            contracts.setting = setting;
            contractAddrs.setting = setting.address;
            return deployer.deploy(SettingStorage, contracts.setting.address);
        })
        .then(settingStorage => {
            checkUndefined('settingStorage', settingStorage);
            contracts.settingStorage = settingStorage;
            contractAddrs.settingStorage = settingStorage.address;
            return contracts.setting.setStorage(contracts.settingStorage.address);
        })
        .then(receipt => {
            console.log('setting.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Setting'), contracts.setting.address);
        })

        // File and FileStorage deploy
        .then(receipt => {
            console.log('resolver.setAddress(Setting) receipts: ', receipt);
            return deployer.deploy(File, contracts.resolver.address);
        })
        .then(file => {
            checkUndefined('file', file);
            contracts.file = file;
            contractAddrs.file = file.address;
            return deployer.deploy(FileStorage, contracts.file.address);
        })
        .then(fileStorage => {
            checkUndefined('fileStorage', fileStorage);
            contracts.fileStorage = fileStorage;
            contractAddrs.fileStorage = fileStorage.address;
            return contracts.file.setStorage(contracts.fileStorage.address);
        })
        .then(receipt => {
            console.log('file.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('File'), contracts.file.address);
        })




        // Monitor and MonitorStorage deploy
        .then(receipt => {
            console.log('resolver.setAddress(File) receipts: ', receipt);
            return deployer.deploy(Monitor, contracts.resolver.address);
        })
        .then(monitor => {
            checkUndefined('monitor', monitor);
            contracts.monitor = monitor;
            contractAddrs.monitor = monitor.address;
            return deployer.deploy(MonitorStorage, contracts.monitor.address);
        })
        .then(monitorStorage => {
            checkUndefined('monitorStorage', monitorStorage);
            contracts.monitorStorage = monitorStorage;
            contractAddrs.monitorStorage = monitorStorage.address;
            return contracts.monitor.setStorage(contracts.monitorStorage.address);
        })
        .then(receipt => {
            console.log('monitor.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Monitor'), contracts.monitor.address);
        })


        // User and UserStorage deploy
        .then(receipt => {
            console.log('resolver.setAddress(Monitor) receipts: ', receipt);
            return deployer.deploy(User, contracts.resolver.address);
        })
        .then((user) => {
            checkUndefined('user', user);
            contracts.user = user;
            contractAddrs.user = user.address;
            return deployer.deploy(UserStorage, contracts.user.address);
        })
        .then(userStorage => {
            checkUndefined('userStorage', userStorage);
            contracts.userStorage = userStorage;
            contractAddrs.userStorage = userStorage.address;
            return contracts.user.setStorage(contracts.userStorage.address);
        })
        .then(receipt => {
            console.log('user.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('User'), contracts.user.address);
        })

        // Node and NodeStorage deploy
        .then(receipt => {
            console.log('resolver.setAddress(User) receipts: ', receipt);
            return deployer.deploy(Node, contracts.resolver.address);
        })
        .then(node => {
            checkUndefined('node', node);
            contracts.node = node;
            contractAddrs.node = node.address;
            return deployer.deploy(NodeStorage, contracts.node.address);
        })
        .then(nodeStorage => {
            checkUndefined('nodeStorage', nodeStorage);
            contracts.nodeStorage = nodeStorage;
            contractAddrs.nodeStorage = nodeStorage.address;
            return contracts.node.setStorage(contracts.nodeStorage.address);
        })
        .then(receipt => {
            console.log('node.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Node'), contracts.node.address);
        })

        // Task and TaskStorage deploy
        .then(receipt => {
            console.log('resolver.setAddress(Node) receipts: ', receipt);
            return deployer.deploy(Task, contracts.resolver.address);
        })
        .then(task => {
            checkUndefined('task', task);
            contracts.task = task;
            contractAddrs.task = task.address;
            return deployer.deploy(TaskStorage, contracts.task.address);
        })
        .then(taskStorage => {
            checkUndefined('taskStorage', taskStorage);
            contracts.taskStorage = taskStorage;
            contractAddrs.taskStorage = taskStorage.address;
            return contracts.task.setStorage(contracts.taskStorage.address);
        })
        .then(receipt => {
            console.log('task.setStorage receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Task'), contracts.task.address);
        })

        .then(receipt => {
            console.log('resolver.setAddress(Task) receipts: ', receipt);
            return deployer.deploy(NodeSelectorForTest);
        })

        .then(nodeSelectorForTest => {
            checkUndefined('nodeSelectorForTest', nodeSelectorForTest);
            contracts.nodeSelectorForTest = nodeSelectorForTest;
            contractAddrs.nodeSelectorForTest = nodeSelectorForTest.address;
            return deployer.deploy(ChainStorage);
        })

        // refreshCache
        .then(chainStorage => {
            checkUndefined('chainStorage', chainStorage);
            contracts.chainStorage = chainStorage;
            contractAddrs.chainStorage = chainStorage.address;
            return contracts.chainStorage.initialize(contracts.resolver.address);
        })
        .then(receipt => {
            console.log('chainStorage.initialize receipt: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('ChainStorage'), contractAddrs.chainStorage);
        })
        .then(receipt => {
            console.log('resolver.setAddress(ChainStorage) receipts: ', receipt);
            return contracts.file.refreshCache();
        })
        .then(receipt => {
            console.log('file.refreshCache receipt: ', receipt);
            return contracts.user.refreshCache();
        })
        .then(receipt => {
            console.log('user.refreshCache receipt: ', receipt);
            return contracts.node.refreshCache();
        })
        .then(receipt => {
            console.log('node.refreshCache receipt: ', receipt);
            return contracts.task.refreshCache();
        })
        .then(receipt => {
            console.log('task.refreshCache receipt: ', receipt);
            return contracts.chainStorage.refreshCache();
        })
        .then(receipt => {
            console.log('chainStorage.refreshCache receipt: ', receipt);
            return contracts.monitor.refreshCache();
        })

        // save contract addresses
        .then(receipt => {
            console.log('monitor.refreshCache receipt: ', receipt);
            console.log("contracts deployment finished\n\n");
            const addrs = JSON.stringify(contractAddrs, null, '\t');
            fs.writeFile('contractAddrs.json', addrs, (err) => {
                if (err) {
                    throw err;
                }
                console.log("contractAddrs saved");
                console.log(Web3Utils.fromAscii('XXXTask'));
            });
        });
};
