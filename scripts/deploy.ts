// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Resolver = await ethers.getContractFactory("Resolver");
  const resolver = await Resolver.deploy();

  const Setting = await ethers.getContractFactory("Setting");
  const setting = await Setting.deploy();

  const SettingStorage = await ethers.getContractFactory("SettingStorage");
  const settingStorage = await SettingStorage.deploy(setting.address);

  const File = await ethers.getContractFactory("File");
  const file = await File.deploy(resolver.address);

  const FileStorage = await ethers.getContractFactory("FileStorage");
  const fileStorage = await FileStorage.deploy(file.address);

  const User = await ethers.getContractFactory("User");
  const user = await User.deploy(resolver.address);

  const UserStorage = await ethers.getContractFactory("UserStorage");
  const userStorage = await UserStorage.deploy(user.address);

  const Node = await ethers.getContractFactory("Node");
  const node = await Node.deploy(resolver.address);

  const NodeStorage = await ethers.getContractFactory("NodeStorage");
  const nodeStorage = await NodeStorage.deploy(node.address);

  const Task = await ethers.getContractFactory("Task");
  const task = await Task.deploy(resolver.address);

  const TaskStorage = await ethers.getContractFactory("TaskStorage");
  const taskStorage = await TaskStorage.deploy(task.address);

  await resolver.deployed();
  await setting.deployed();
  await settingStorage.deployed();
  await file.deployed();
  await fileStorage.deployed();
  await user.deployed();
  await userStorage.deployed();
  await nodeStorage.deployed();

  console.log("Resolver deployed to:", resolver.address);
  console.log("Setting deployed to:", setting.address);
  console.log("SettingStorage deployed to:", settingStorage.address);
  console.log("File deployed to:", file.address);
  console.log("FileStorage deployed to:", fileStorage.address);
  console.log("User deployed to:", user.address);
  console.log("NodeStorage deployed to:", nodeStorage.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
