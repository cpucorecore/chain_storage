function checkUndefined(objName, obj) {
    if (obj == undefined) {
        console.log(objName+': undefined');
        process.exit(-1);
    } else {
        console.log(objName+':'+obj.address);
    }
}

exports.checkUndefined = checkUndefined;