const csv = require("csv")
const data = require("./fbredwalkdata.json")

let output = "dateTime,distanceWalked,environment,locomotion,rooms,vp\n" + Object.entries(data.data).map(([index, entry]) => {
    return Object.entries(entry).map(([key, value]) => {
        return value.toString()
    }).join(",")
}).join("\n")


console.log(output)




