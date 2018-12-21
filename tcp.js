var user = 'onos';
var password = 'rocks';
var onos = 'localhost';
var controls = {};

//
setFlow('tcp_flood',
    { keys: 'ipdestination,tcpsourceport', value: 'frames', log: true });

setThreshold('tcp_requests',
    { metric: 'tcp_flood', value: 1000, byFlow: true, timeout: 1 });

setEventHandler(function (evt) {
    // don't consider inter-switch links
    var link = topologyInterfaceToLink(evt.agent, evt.dataSource);
    if (link) return;

    // get port information
    var port = topologyInterfaceToPort(evt.agent, evt.dataSource);
    if (!port) return;

    // need OpenFlow info to create ONOS filtering rule
    if (!port.dpid || !port.ofport) return;

    // we already have a control for this flow
    if (controls[evt.flowKey]) return;

    var [ipdestination,tcpsourceport] = evt.flowKey.split(',');
    var msg = {
        flows: [
            {
                priority: 4000,
                timeout: 0,
                isPermanent: true,
                deviceId: 'of:' + port.dpid,
                treatment: [],
                selector: {
                    criteria: [
                        { type: 'IN_PORT', port: port.ofport },
                        { type: 'ETH_TYPE', ethType: '0x800' },
                        { type: 'IPV4_DST', ip: ipdestination + '/32' },
                        { type: 'IP_PROTO', protocol: '6' },
                        { type: 'TCP_SRC', tcpPort: tcpsourceport }
                    ]
                }
            }
        ]
    };

    var resp = http2({
        url: 'http://' + onos + ':8181/onos/v1/flows?appId=policy',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        operation: 'post',
        user: user,
        password: password,
        body: JSON.stringify(msg)
    });

    var { deviceId, flowId } = JSON.parse(resp.body).flows[0];
    controls[evt.flowKey] = {
        time: Date.now(),
        threshold: evt.thresholdID,
        agent: evt.agent,
        metric: evt.dataSource + '.' + evt.metric,
        deviceId: deviceId,
        flowId: flowId
    };

    logInfo("blocking " + evt.flowKey);
}, ['tcp_requests']);

setIntervalHandler(function () {
    var now = Date.now();
    for (var key in controls) {
        let rec = controls[key];

        // keep control for at least 10 seconds
        if (now - rec.time < 10000) continue;
        // keep control if threshold still triggered
        if (thresholdTriggered(rec.threshold, rec.agent, rec.metric, key)) continue;

        var resp = http2({
            url: 'http://' + onos + ':8181/onos/v1/flows/'
                + encodeURIComponent(rec.deviceId) + '/' + encodeURIComponent(rec.flowId),
            headers: { 'Accept': 'application/json' },
            operation: 'delete',
            user: user,
            password: password
        });

        delete controls[key];

        logInfo("unblocking " + key);
    }
});
