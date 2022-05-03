package com;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.fisco.bcos.sdk.abi.FunctionEncoder;
import org.fisco.bcos.sdk.abi.FunctionReturnDecoder;
import org.fisco.bcos.sdk.abi.TypeReference;
import org.fisco.bcos.sdk.abi.datatypes.Address;
import org.fisco.bcos.sdk.abi.datatypes.Bool;
import org.fisco.bcos.sdk.abi.datatypes.DynamicArray;
import org.fisco.bcos.sdk.abi.datatypes.Event;
import org.fisco.bcos.sdk.abi.datatypes.Function;
import org.fisco.bcos.sdk.abi.datatypes.Type;
import org.fisco.bcos.sdk.abi.datatypes.Utf8String;
import org.fisco.bcos.sdk.abi.datatypes.generated.Bytes32;
import org.fisco.bcos.sdk.abi.datatypes.generated.Uint256;
import org.fisco.bcos.sdk.abi.datatypes.generated.tuples.generated.Tuple1;
import org.fisco.bcos.sdk.abi.datatypes.generated.tuples.generated.Tuple2;
import org.fisco.bcos.sdk.client.Client;
import org.fisco.bcos.sdk.contract.Contract;
import org.fisco.bcos.sdk.crypto.CryptoSuite;
import org.fisco.bcos.sdk.crypto.keypair.CryptoKeyPair;
import org.fisco.bcos.sdk.eventsub.EventCallback;
import org.fisco.bcos.sdk.model.CryptoType;
import org.fisco.bcos.sdk.model.TransactionReceipt;
import org.fisco.bcos.sdk.model.callback.TransactionCallback;
import org.fisco.bcos.sdk.transaction.model.exception.ContractException;

@SuppressWarnings("unchecked")
public class Monitor extends Contract {
    public static final String[] BINARY_ARRAY = {};

    public static final String BINARY = org.fisco.bcos.sdk.utils.StringUtils.joinAll("", BINARY_ARRAY);

    public static final String[] SM_BINARY_ARRAY = {};

    public static final String SM_BINARY = org.fisco.bcos.sdk.utils.StringUtils.joinAll("", SM_BINARY_ARRAY);

    public static final String[] ABI_ARRAY = {"[{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"maintain\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"resolver\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"getImports\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"setOwner\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"name\",\"type\":\"bytes32\"}],\"name\":\"getAddress\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"},{\"name\":\"ext\",\"type\":\"string\"}],\"name\":\"register\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"getStorage\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"manager\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"exist\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"},{\"name\":\"tid\",\"type\":\"uint256\"}],\"name\":\"resetCurrentTid\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"deRegister\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"contractName\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"name\",\"type\":\"bytes32\"}],\"name\":\"addAddress\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"},{\"name\":\"tid\",\"type\":\"uint256\"}],\"name\":\"checkTask\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"value\",\"type\":\"address\"}],\"name\":\"setStorage\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"online\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"loadCurrentTid\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_manager\",\"type\":\"address\"}],\"name\":\"setManager\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"refreshCache\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"name\":\"_resolver\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"previousValue\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"newValue\",\"type\":\"address\"}],\"name\":\"StorageChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"previousValue\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"newValue\",\"type\":\"address\"}],\"name\":\"OwnerChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"previousValue\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"newValue\",\"type\":\"address\"}],\"name\":\"ManagerChanged\",\"type\":\"event\"}]"};

    public static final String ABI = org.fisco.bcos.sdk.utils.StringUtils.joinAll("", ABI_ARRAY);

    public static final String FUNC_MAINTAIN = "maintain";

    public static final String FUNC_RESOLVER = "resolver";

    public static final String FUNC_GETIMPORTS = "getImports";

    public static final String FUNC_SETOWNER = "setOwner";

    public static final String FUNC_GETADDRESS = "getAddress";

    public static final String FUNC_REGISTER = "register";

    public static final String FUNC_GETSTORAGE = "getStorage";

    public static final String FUNC_MANAGER = "manager";

    public static final String FUNC_EXIST = "exist";

    public static final String FUNC_RESETCURRENTTID = "resetCurrentTid";

    public static final String FUNC_DEREGISTER = "deRegister";

    public static final String FUNC_CONTRACTNAME = "contractName";

    public static final String FUNC_ADDADDRESS = "addAddress";

    public static final String FUNC_OWNER = "owner";

    public static final String FUNC_CHECKTASK = "checkTask";

    public static final String FUNC_SETSTORAGE = "setStorage";

    public static final String FUNC_ONLINE = "online";

    public static final String FUNC_LOADCURRENTTID = "loadCurrentTid";

    public static final String FUNC_SETMANAGER = "setManager";

    public static final String FUNC_REFRESHCACHE = "refreshCache";

    public static final Event STORAGECHANGED_EVENT = new Event("StorageChanged", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}));
    ;

    public static final Event OWNERCHANGED_EVENT = new Event("OwnerChanged", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}));
    ;

    public static final Event MANAGERCHANGED_EVENT = new Event("ManagerChanged", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}));
    ;

    protected Monitor(String contractAddress, Client client, CryptoKeyPair credential) {
        super(getBinary(client.getCryptoSuite()), contractAddress, client, credential);
    }

    public static String getBinary(CryptoSuite cryptoSuite) {
        return (cryptoSuite.getCryptoTypeConfig() == CryptoType.ECDSA_TYPE ? BINARY : SM_BINARY);
    }

    public TransactionReceipt maintain(String addr) {
        final Function function = new Function(
                FUNC_MAINTAIN, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] maintain(String addr, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_MAINTAIN, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForMaintain(String addr) {
        final Function function = new Function(
                FUNC_MAINTAIN, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getMaintainInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_MAINTAIN, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public String resolver() throws ContractException {
        final Function function = new Function(FUNC_RESOLVER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeCallWithSingleValueReturn(function, String.class);
    }

    public List getImports() throws ContractException {
        final Function function = new Function(FUNC_GETIMPORTS, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<DynamicArray<Bytes32>>() {}));
        List<Type> result = (List<Type>) executeCallWithSingleValueReturn(function, List.class);
        return convertToNative(result);
    }

    public TransactionReceipt setOwner(String _owner) {
        final Function function = new Function(
                FUNC_SETOWNER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(_owner)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] setOwner(String _owner, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_SETOWNER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(_owner)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForSetOwner(String _owner) {
        final Function function = new Function(
                FUNC_SETOWNER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(_owner)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getSetOwnerInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_SETOWNER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public String getAddress(byte[] name) throws ContractException {
        final Function function = new Function(FUNC_GETADDRESS, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.generated.Bytes32(name)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeCallWithSingleValueReturn(function, String.class);
    }

    public TransactionReceipt register(String addr, String ext) {
        final Function function = new Function(
                FUNC_REGISTER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.Utf8String(ext)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] register(String addr, String ext, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_REGISTER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.Utf8String(ext)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForRegister(String addr, String ext) {
        final Function function = new Function(
                FUNC_REGISTER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.Utf8String(ext)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple2<String, String> getRegisterInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_REGISTER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}, new TypeReference<Utf8String>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple2<String, String>(

                (String) results.get(0).getValue(), 
                (String) results.get(1).getValue()
                );
    }

    public String getStorage() throws ContractException {
        final Function function = new Function(FUNC_GETSTORAGE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeCallWithSingleValueReturn(function, String.class);
    }

    public String manager() throws ContractException {
        final Function function = new Function(FUNC_MANAGER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeCallWithSingleValueReturn(function, String.class);
    }

    public TransactionReceipt exist(String addr) {
        final Function function = new Function(
                FUNC_EXIST, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] exist(String addr, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_EXIST, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForExist(String addr) {
        final Function function = new Function(
                FUNC_EXIST, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getExistInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_EXIST, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public Tuple1<Boolean> getExistOutput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getOutput();
        final Function function = new Function(FUNC_EXIST, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bool>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<Boolean>(

                (Boolean) results.get(0).getValue()
                );
    }

    public TransactionReceipt resetCurrentTid(String addr, BigInteger tid) {
        final Function function = new Function(
                FUNC_RESETCURRENTTID, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.generated.Uint256(tid)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] resetCurrentTid(String addr, BigInteger tid, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_RESETCURRENTTID, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.generated.Uint256(tid)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForResetCurrentTid(String addr, BigInteger tid) {
        final Function function = new Function(
                FUNC_RESETCURRENTTID, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.generated.Uint256(tid)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple2<String, BigInteger> getResetCurrentTidInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_RESETCURRENTTID, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}, new TypeReference<Uint256>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple2<String, BigInteger>(

                (String) results.get(0).getValue(), 
                (BigInteger) results.get(1).getValue()
                );
    }

    public TransactionReceipt deRegister(String addr) {
        final Function function = new Function(
                FUNC_DEREGISTER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] deRegister(String addr, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_DEREGISTER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForDeRegister(String addr) {
        final Function function = new Function(
                FUNC_DEREGISTER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getDeRegisterInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_DEREGISTER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public String contractName() throws ContractException {
        final Function function = new Function(FUNC_CONTRACTNAME, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Utf8String>() {}));
        return executeCallWithSingleValueReturn(function, String.class);
    }

    public TransactionReceipt addAddress(byte[] name) {
        final Function function = new Function(
                FUNC_ADDADDRESS, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.generated.Bytes32(name)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] addAddress(byte[] name, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_ADDADDRESS, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.generated.Bytes32(name)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForAddAddress(byte[] name) {
        final Function function = new Function(
                FUNC_ADDADDRESS, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.generated.Bytes32(name)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<byte[]> getAddAddressInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_ADDADDRESS, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<byte[]>(

                (byte[]) results.get(0).getValue()
                );
    }

    public String owner() throws ContractException {
        final Function function = new Function(FUNC_OWNER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeCallWithSingleValueReturn(function, String.class);
    }

    public TransactionReceipt checkTask(String addr, BigInteger tid) {
        final Function function = new Function(
                FUNC_CHECKTASK, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.generated.Uint256(tid)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] checkTask(String addr, BigInteger tid, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_CHECKTASK, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.generated.Uint256(tid)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForCheckTask(String addr, BigInteger tid) {
        final Function function = new Function(
                FUNC_CHECKTASK, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr), 
                new org.fisco.bcos.sdk.abi.datatypes.generated.Uint256(tid)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple2<String, BigInteger> getCheckTaskInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_CHECKTASK, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}, new TypeReference<Uint256>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple2<String, BigInteger>(

                (String) results.get(0).getValue(), 
                (BigInteger) results.get(1).getValue()
                );
    }

    public Tuple1<Boolean> getCheckTaskOutput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getOutput();
        final Function function = new Function(FUNC_CHECKTASK, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bool>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<Boolean>(

                (Boolean) results.get(0).getValue()
                );
    }

    public TransactionReceipt setStorage(String value) {
        final Function function = new Function(
                FUNC_SETSTORAGE, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(value)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] setStorage(String value, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_SETSTORAGE, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(value)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForSetStorage(String value) {
        final Function function = new Function(
                FUNC_SETSTORAGE, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(value)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getSetStorageInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_SETSTORAGE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public TransactionReceipt online(String addr) {
        final Function function = new Function(
                FUNC_ONLINE, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] online(String addr, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_ONLINE, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForOnline(String addr) {
        final Function function = new Function(
                FUNC_ONLINE, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getOnlineInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_ONLINE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public TransactionReceipt loadCurrentTid(String addr) {
        final Function function = new Function(
                FUNC_LOADCURRENTTID, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] loadCurrentTid(String addr, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_LOADCURRENTTID, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForLoadCurrentTid(String addr) {
        final Function function = new Function(
                FUNC_LOADCURRENTTID, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(addr)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getLoadCurrentTidInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_LOADCURRENTTID, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public Tuple1<BigInteger> getLoadCurrentTidOutput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getOutput();
        final Function function = new Function(FUNC_LOADCURRENTTID, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<BigInteger>(

                (BigInteger) results.get(0).getValue()
                );
    }

    public TransactionReceipt setManager(String _manager) {
        final Function function = new Function(
                FUNC_SETMANAGER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(_manager)), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] setManager(String _manager, TransactionCallback callback) {
        final Function function = new Function(
                FUNC_SETMANAGER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(_manager)), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForSetManager(String _manager) {
        final Function function = new Function(
                FUNC_SETMANAGER, 
                Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(_manager)), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public Tuple1<String> getSetManagerInput(TransactionReceipt transactionReceipt) {
        String data = transactionReceipt.getInput().substring(10);
        final Function function = new Function(FUNC_SETMANAGER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        List<Type> results = FunctionReturnDecoder.decode(data, function.getOutputParameters());
        return new Tuple1<String>(

                (String) results.get(0).getValue()
                );
    }

    public TransactionReceipt refreshCache() {
        final Function function = new Function(
                FUNC_REFRESHCACHE, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return executeTransaction(function);
    }

    public byte[] refreshCache(TransactionCallback callback) {
        final Function function = new Function(
                FUNC_REFRESHCACHE, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return asyncExecuteTransaction(function, callback);
    }

    public String getSignedTransactionForRefreshCache() {
        final Function function = new Function(
                FUNC_REFRESHCACHE, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return createSignedTransaction(function);
    }

    public List<StorageChangedEventResponse> getStorageChangedEvents(TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = extractEventParametersWithLog(STORAGECHANGED_EVENT, transactionReceipt);
        ArrayList<StorageChangedEventResponse> responses = new ArrayList<StorageChangedEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            StorageChangedEventResponse typedResponse = new StorageChangedEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.previousValue = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.newValue = (String) eventValues.getIndexedValues().get(1).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public void subscribeStorageChangedEvent(String fromBlock, String toBlock, List<String> otherTopics, EventCallback callback) {
        String topic0 = eventEncoder.encode(STORAGECHANGED_EVENT);
        subscribeEvent(ABI,BINARY,topic0,fromBlock,toBlock,otherTopics,callback);
    }

    public void subscribeStorageChangedEvent(EventCallback callback) {
        String topic0 = eventEncoder.encode(STORAGECHANGED_EVENT);
        subscribeEvent(ABI,BINARY,topic0,callback);
    }

    public List<OwnerChangedEventResponse> getOwnerChangedEvents(TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = extractEventParametersWithLog(OWNERCHANGED_EVENT, transactionReceipt);
        ArrayList<OwnerChangedEventResponse> responses = new ArrayList<OwnerChangedEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            OwnerChangedEventResponse typedResponse = new OwnerChangedEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.previousValue = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.newValue = (String) eventValues.getIndexedValues().get(1).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public void subscribeOwnerChangedEvent(String fromBlock, String toBlock, List<String> otherTopics, EventCallback callback) {
        String topic0 = eventEncoder.encode(OWNERCHANGED_EVENT);
        subscribeEvent(ABI,BINARY,topic0,fromBlock,toBlock,otherTopics,callback);
    }

    public void subscribeOwnerChangedEvent(EventCallback callback) {
        String topic0 = eventEncoder.encode(OWNERCHANGED_EVENT);
        subscribeEvent(ABI,BINARY,topic0,callback);
    }

    public List<ManagerChangedEventResponse> getManagerChangedEvents(TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = extractEventParametersWithLog(MANAGERCHANGED_EVENT, transactionReceipt);
        ArrayList<ManagerChangedEventResponse> responses = new ArrayList<ManagerChangedEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            ManagerChangedEventResponse typedResponse = new ManagerChangedEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.previousValue = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.newValue = (String) eventValues.getIndexedValues().get(1).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public void subscribeManagerChangedEvent(String fromBlock, String toBlock, List<String> otherTopics, EventCallback callback) {
        String topic0 = eventEncoder.encode(MANAGERCHANGED_EVENT);
        subscribeEvent(ABI,BINARY,topic0,fromBlock,toBlock,otherTopics,callback);
    }

    public void subscribeManagerChangedEvent(EventCallback callback) {
        String topic0 = eventEncoder.encode(MANAGERCHANGED_EVENT);
        subscribeEvent(ABI,BINARY,topic0,callback);
    }

    public static Monitor load(String contractAddress, Client client, CryptoKeyPair credential) {
        return new Monitor(contractAddress, client, credential);
    }

    public static Monitor deploy(Client client, CryptoKeyPair credential, String _resolver) throws ContractException {
        String encodedConstructor = FunctionEncoder.encodeConstructor(Arrays.<Type>asList(new org.fisco.bcos.sdk.abi.datatypes.Address(_resolver)));
        return deploy(Monitor.class, client, credential, getBinary(client.getCryptoSuite()), encodedConstructor);
    }

    public static class StorageChangedEventResponse {
        public TransactionReceipt.Logs log;

        public String previousValue;

        public String newValue;
    }

    public static class OwnerChangedEventResponse {
        public TransactionReceipt.Logs log;

        public String previousValue;

        public String newValue;
    }

    public static class ManagerChangedEventResponse {
        public TransactionReceipt.Logs log;

        public String previousValue;

        public String newValue;
    }
}
