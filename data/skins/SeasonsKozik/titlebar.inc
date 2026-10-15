## titlebar for weewx skins
## Copyright Tom Keffer, Matthew Wall
## See LICENSE.txt for your rights
#errorCatcher Echo
#encoding UTF-8

#set $show_rss = $to_bool($DisplayOptions.get('show_rss', True))
#set $show_reports = $to_bool($DisplayOptions.get('show_reports', True))

<div id="title_bar">
  <div id="title">
    <h1 class="page_title">$station.location</h1>
    <p class="lastupdate">$current.dateTime</p>
## LOCAL CHANGE (kozik): data freshness indicator. The browser compares the
## latest record time with its own clock, so a stale page served by a healthy
## nginx still shows red. Leave the lastupdate line above unchanged: Zabbix
## weewx_website_health.sh parses it.
    <p class="lastupdate" id="freshness" data-ts="$current.dateTime.raw" data-interval="$current.interval.raw"></p>
    <script>
      (function () {
        var e = document.getElementById('freshness');
        var ts = +e.dataset.ts, iv = (+e.dataset.interval || 10) * 60;
        function check() {
          var age = Date.now() / 1000 - ts, ok = age < 2 * iv + 300;
          e.style.color = ok ? 'rgb(46,125,50)' : 'rgb(198,40,40)';
          e.textContent = (ok ? '● Live' : '● Stale') + ' (data ' + Math.round(age / 60) + ' min old)';
        }
        check(); setInterval(check, 60000);
      })();
    </script>
  </div>
#if $show_rss
  <div id="rss_link"><a href="rss.xml">RSS</a></div>
#end if
#if $show_reports
  <div id="reports">
    $gettext("Monthly Reports"):
    <select name="reports" onchange="openTabularFile(value)">
      #for $monthYear in $SummaryByMonth
      <option value="$monthYear">$monthYear</option>
      #end for
      <option selected>- $gettext("select month") -</option>
    </select>
    <br/>
    $gettext("Yearly Reports"):
    <select name="reports" onchange="openTabularFile(value)">
      #for $yr in $SummaryByYear
      <option value="$yr">$yr</option>
      #end for
      <option selected>- $gettext("select year") -</option>
    </select>
    <br/>
  </div>
#end if
</div>
