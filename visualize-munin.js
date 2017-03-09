// to c&p into the js console on https://admin.internal.magento.cloud:4443/

(function () {
  var script = document.createElement("script");
  script.src = 'https://code.jquery.com/jquery-3.1.1.slim.min.js';
  script.type = 'text/javascript';
  document.getElementsByTagName("head")[0].appendChild(script);

  var link = document.createElement("link");
  link.href = 'https://rawgit.com/keithbentrup/279279ee7f869adc564c5fc4879903f8/raw/1069cf727515bd87e4708a4c4d0c0a9f5b6d530f/munin.css';
  link.rel ="stylesheet";
  link.type="text/css";
  document.getElementsByTagName("head")[0].appendChild(link);

})();

window.munin = {

  validPeriodOpts : ['hour', 'day', 'week', 'month', 'year'],

  validPeriodRegExp : new RegExp('^(20\\d\{2\}\-\[0\-1\]\\d\-\[0\-3\]\\d \[0\-2\]\\d:\[0\-5\]\\d:\[0\-5\]\\d|'+munin.validPeriodOpts.join('|')+')$'),

  validTypeOpts : ['load', 'cpu', 'diskstats_latency', 'memory', 'swap', 'fw_conntrack'],

  PMETGroup : {
    name: 'us.magento.cloud',
    hosts: [
      {
        name: 'i-2c615fb6.platform.sh',
        cpu: 32,
        projects: [
          { name : "ref-PMET", id: "z6ecydpeqprxe"},
          { name : "ref-ltaddonio", id: "zd3nr5j5i23hi"},
          { name : "ref-duselton", id: "yjrmflkpme6li"},
          { name : "ref-amolloy", id: "hf4ad3texujow"},
          { name : "ref-bmeixner", id: "2kfpmtxuk4tnc"},
          { name : "demo-ltaddonio", id: "jyvegogwpv3su"},
          { name : "b2b-PMET", id: "zr3k7yaz4skra"},
          { name : "b2b-ltaddonio", id: "a3x3dstsphuom"},
          { name : "ref-skukla", id: "jgybzwuo3hz2y"},
          { name : "ref-rgassman", id: "tqzufyfw3g2ag"}
        ]
      },
      {
        name: 'i-df9c0544.platform.sh',
        cpu: 16,
        projects: [
          { name : "ref-ngolubiewski", id: "awnfc4ftjkhvc"},
          { name : "ref-mwiseler", id: "dheue7ci2ejza"},
          { name : "ref-aaron", id: "txhkwfvmubcmy"},
          { name : "demo-skukla", id: "36fjujtek7d7m"},
          { name : "demo-PMET2", id: "xf6pteamwisvy"},
          { name : "demo-PMET", id: "xpwgonshm6qm2"},
          { name : "demo-mwiseler", id: "gdprlmsp3syac"},
          { name : "demo-mgeorge", id: "3iybopuopjry4"},
          { name : "demo-jumorrow", id: "jbknjzf7kseyc"},
          { name : "demo-aaron", id: "l5g5iozdt7fmo"}
        ]
      },
      {
        name: 'i-9febe91b.platform.sh',
        cpu: 16,
        projects: [
          { name : "ref-mgeorge", id: "xdw4lfjm5v5c2"},
          { name : "ref-jumorrow", id: "v5mgc5i33x26m"},
          { name : "ref-henfiedler", id: "y4wcaskwfjinm"},
          { name : "ref-aakoch", id: "gnvyatgvcfroa"},
          { name : "demo-henfiedler", id: "p3ajtccyn5j3w"},
          { name : "demo-duselton", id: "okwrpgben2gzg"},
          { name : "demo-bmeixner", id: "ql4s37mg6ar4w"},
          { name : "demo-aakoch", id: "rnw4cirxgmzx4"},
        ]
      },
      {
        name: 'i-7b608ce8.platform.sh',
        cpu: 8,
        projects: [
          { name : "ref-trials", id: "5c3fsutojnf5q"},
          { name : "b2b-ngolubiewski", id: "uhimffdzz4njc"},
          { name : "b2b-duselton", id: "73xge34nt3ft4"},
          { name : "b2b-jumorrow", id: "iwowdrifhd4n4"},
          { name : "b2b-bmeixner", id: "wvkqe7x3dkvou"},
          { name : "b2b-aaron", id: "nz6a3ko23leki"}
        ]
      },
      {
        name: 'i-f14f76ff.platform.sh',
        cpu: 8,
        projects: [
          { name : "demo-ngolubiewski", id: "2m6nruvxa44h6"},
          { name : "b2b-skukla", id: "6h4sexqr4xp3i"},
          { name : "b2b-mwiseler", id: "tqpyf6hl7f6ds"},
          { name : "b2b-mgeorge", id: "bzpcwticvqp2a"},
          { name : "b2b-henfieldler", id: "qr5zdyo6gdalq"},
          { name : "b2b-amolloy", id: "e6bm2ixhwlbwa"},
          { name : "b2b-aakoch", id: "takgjynr4dqla"}
        ]
      }
    ]
  },

  getChart : function (type, period, group, host) {
    // check some inputs

    if (!this.validTypeOpts.includes(type)) {
      throw new TypeError('Invalid type: ' + type + '. Must be one of: ' + this.validTypeOpts.join(', '));
    } else if (!this.validPeriodRegExp.test(period)) {
      throw new RangeError('Period must be one of: ' + this.validPeriodOpts.join(', ') +
        ' or formatted timestamp (ex. YYYY-MM-DD HH:MM:SS)');
    }

    var imgSrcStr = '/munin-cgi/munin-cgi-graph/' + group + '/' + host + '/' + type + '-';
    if (['day','week','month','year'].includes(period)) {
      return $('<img />', {'src': imgSrcStr + period + '.png'});
    } else {
      var t = period === "hour" ? new Date() : new Date(period + ' GMT'),
        secsSinceEpoch = Math.floor(t.getTime()/1000);
      return $('<img />', {'src': imgSrcStr + 'pinpoint=' + (secsSinceEpoch - 20 * 60) + ',' + (secsSinceEpoch + 20 * 60) + '.png'});
    }

  },

  _alphaSort : function (a, b) {
    if (a.name < b.name) return -1;
    if (a.name > b.name) return 1;
    return 0;
  },

  getPMETTable : function (period) {
    $(document.body).children().remove();
    $('<table id="pmet-resources"><tr id="host-header"></tr></table>').appendTo(document.body);
    this.PMETGroup.hosts.forEach(function (host) {
      var thHTML = "<b>" + host.name + "</b>, " + host.cpu + " cpus<br><br>";
      host.projects.sort(munin._alphaSort).forEach(function (project) {
        thHTML += project.name + " (" + project.id + ")<br>"
      });
      $(thHTML).appendTo('#host-header').wrapAll('<th></th>');
    });
    this.validTypeOpts.forEach(function(type) {
      var type = type;
      $('<tr id="' + type + '-row"></tr>').appendTo('#pmet-resources');
      munin.PMETGroup.hosts.forEach(function (host) {
        munin.getChart(type, period, munin.PMETGroup.name, host.name).appendTo('#' + type + '-row').wrap('<td></td>')
      });
    })
  },

  displayPMETGroupByPeriod : function (period) {
    this.getPMETTable();
    setInterval(5*60*1000, this.getPMETTable);
  },

  addTimestampInput : function () {
    $('<input id="datetime" style="float:right; position: absolute" placeholder="YYYY-MM-DD HH:MM:SS">')
      .prependTo(document.body)
      .change(function () {

      });
  }

}
