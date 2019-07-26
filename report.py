#!/usr/bin/env python3

import collections
import os
import pprint
import re
from pathlib import Path
from datetime import datetime

pp = pprint.PrettyPrinter()

tests = [
    'cpp-benchs', 'rust-benchs', 'rust-unittests', 'unittests',
    'tar', 'untar', 'find', 'sort', 'sha256sum', 'sqlite', 'leveldb',
]
colors = ['red', 'blue', 'green', 'orange', 'purple']

re_name   = re.compile('^m3-tests-(' + '|'.join(tests) + ')-(.)-(\S+?)-(\d+)$')
re_test   = re.compile('^Testing "(.*?)" in (.*?):$')
re_failed = re.compile('^!\s+([^:]+):(\d+)\s+(.*?) FAILED$')
re_perf   = re.compile('^.*!\s+([^:]+):(\d+)\s+PERF\s+"(.*?)": (\d+) cycles/iter \(\+/\- ([0-9\-\.]+) with (\d+) runs\)$')
re_shdn   = re.compile('^.*\[kernel\s*@0\].*Shutting down$')

class PerfResult:
    def __init__(self, name, time, variance, runs):
        self.name = name
        self.time = time
        self.variance = variance
        self.runs = runs

    def __repr__(self):
        return "PERF[{}] = {} ({} with {} runs)\n".format(self.name, self.time, self.variance, self.time)

class TestResult:
    def __init__(self, name, desc):
        self.name = name
        self.desc = desc

    def __repr__(self):
        if self.name == "":
            return self.desc
        return self.name + ": " + self.desc

class Result:
    def __init__(self):
        self.failed_tests = 0
        self.succ_tests = 0
        self.failures = []
        self.perfs = {}

    def add_failed_test(self, name, desc):
        self.failures.append(TestResult(name, desc))

    def add_perf(self, pmatch):
        name = re.sub(r"^.*/([^/]+)$", r"\1", pmatch.group(1)) + ": " + pmatch.group(3)
        self.perfs[name] = PerfResult(name,
                                      int(pmatch.group(4)),
                                      float(pmatch.group(5)),
                                      int(pmatch.group(6)))

    def __repr__(self):
        str = "{} / {} succeeded".format(self.failed_tests, self.succ_tests + self.failed_tests)
        if len(self.perfs) > 0:
            str += "\n"
            for p in self.perfs:
                str += "  " + repr(self.perfs[p])
        return str

def file_contents(path):
    with open(path) as f:
        return f.read()

def parse_output(file):
    failed_asserts = 0
    res = Result()
    seen_shutdown = False
    with open(file, 'r') as reader:
        line = reader.readline()
        test = ""
        while line != '':
            line = line.strip()
            tmatch = re_test.match(line)
            if tmatch:
                if test != "":
                    if failed_asserts == 0:
                        res.succ_tests += 1
                    else:
                        res.failed_tests += 1
                    failed_asserts = 0
                test = tmatch.group(1)
            else:
                fmatch = re_failed.match(line)
                if fmatch:
                    res.add_failed_test(fmatch.group(1) + ":" + fmatch.group(2), fmatch.group(3))
                    failed_asserts += 1
                else:
                    pmatch = re_perf.match(line)
                    if pmatch:
                        res.add_perf(pmatch)
                        res.succ_tests += 1
                    elif re_shdn.match(line):
                        seen_shutdown = True

            line = reader.readline()
    if not seen_shutdown:
        res.failed_tests += 1
        res.add_failed_test("", "Test did not complete (no kernel shutdown)")
    return res

def write_html_header(report):
    report.write("<!DOCTYPE html>\n")
    report.write("<html>\n")
    report.write("<head>\n")
    report.write("  <meta charset=\"UTF-8\">\n")
    report.write("  <link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">\n")
    report.write("</head>\n")
    report.write("<body>\n")

def write_html_footer(report):
    report.write("</body>\n")
    report.write("</html>\n")

results = {}
commits = {}
for dir in Path('results').glob('tests-*'):
    dirname = str(dir)[14:]
    results[dirname] = {}
    commits[dirname] = file_contents(str(dir) + '/git-commit')
    for f in os.listdir(dir):
        match = re_name.match(f)
        if match:
            test = match.group(1)
            petype = match.group(2)
            isa = match.group(3)
            bpe = match.group(4)

            if test not in results[dirname]:
                results[dirname][test] = {}
            key = "{}-{}-{}".format(petype, isa, bpe)
            results[dirname][test][key] = parse_output(str(dir) + '/' + str(f) + '/output.txt')

benchs = {}
cfgs = {}
for date in results:
    for test in results[date]:
        for cfg in results[date][test]:
            # only consider the benchmarks with 64 blocks per extent
            if cfg[-3:] != "-64":
                continue
            res = results[date][test][cfg]
            for pname in res.perfs:
                benchs[pname] = 1
            cfgs[cfg] = 1

for date in results:
    for test in results[date]:
        with open('reports/log-' + test + '-' + date + '.html', 'w') as report:
            write_html_header(report)

            report.write("<h2>Results of {} on {}:</h2>".format(test, date))
            for cfg in results[date][test]:
                report.write("<h3>{}: (results/tests-{}/m3-tests-{}-{}/output.txt)</h3>"
                    .format(cfg, date, test, cfg))
                res = results[date][test][cfg]
                report.write("<ul>\n")
                for failed in res.failures:
                    report.write("  <li>{} <span class=\"failed\">failed</span></li>\n".format(failed))
                report.write("</ul>\n")

            write_html_footer(report)

with open('reports/style.css', 'w') as report:
    report.write("""
body {
    font-family: 'Helvetica';
    font-size: 12pt;
}
a {
    color: blue;
    text-decoration: none;
}
a:hover {
    text-decoration: underline;
}
table {
    border: solid 1px black;
    border-collapse: collapse;
    border-spacing: 1em;
    padding: 1em;
}
td, th {
    padding: 1em;
    border: solid 1px black;
}
th {
    background-color: #eeeeee;
}
.success {
    background-color: #cffdd2;
    color: white;
}
.failed {
    background-color: #fdcfcf;
    color: white;
}
span.failed {
    background-color: #fff;
    color: red;
}
""")

with open('reports/summary.html', 'w') as report:
    write_html_header(report)

    report.write("<script src=\"https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.8.0/Chart.min.js\"></script>\n")

    report.write("<table>\n")
    report.write("  <tr>\n")
    report.write("  <th>Tests</th>\n")
    for date in sorted(results.keys()):
        report.write("    <th>{}<br/>(<span title=\"{}\">{}</span>)</th>\n"
            .format(date, commits[date], commits[date][:8]))
    report.write("  <th>Performance</th>\n")
    report.write("  </tr>\n")

    for test in tests:
        report.write("  <tr>\n")
        report.write("    <td><a href=\"{0}.html\">{0}</a></td>\n".format(test))
        for date in sorted(results.keys()):
            succ = 0
            fail = 0
            try:
                for cfg in results[date][test]:
                    res = results[date][test][cfg]
                    succ += res.succ_tests
                    fail += res.failed_tests
            except:
                pass
            report.write("    <td class=\"{}\"><a href=\"log-{}-{}.html\">{} / {}</a></td>\n"
                .format("success" if fail == 0 else "failed", test, date, succ, fail + succ))

        # collect relative performance changes
        base = {}
        rel = {}
        for date in sorted(results.keys()):
            for cfg in cfgs:
                if not cfg in base:
                    base[cfg] = {}
                    rel[cfg] = {}

                try:
                    res = results[date][test][cfg]
                    for pname in res.perfs:
                        perf = res.perfs[pname]
                        if perf.name in base[cfg]:
                            rel[cfg][perf.name].append(str(perf.time / base[cfg][perf.name]))
                        else:
                            base[cfg][perf.name] = perf.time
                            rel[cfg][perf.name] = ["1"]
                except:
                    rel[cfg][perf.name].append("null")

        chart_name = 'changes_' + re.sub(r'[^a-zA-Z0-9_]', '', test)
        report.write("    <td>\n")
        report.write("    <div style=\"width: 200px; height: 80px\">\n")
        report.write("      <canvas id=\"{}\"></canvas>\n".format(chart_name))
        report.write("    </div>\n")
        report.write("    <script type=\"text/javascript\">\n")
        report.write("    var changeData{} = {{\n".format(chart_name))
        report.write("      labels: [")
        for date in sorted(results.keys()):
            report.write("\"{}\", ".format(date))
        report.write("      ],\n")
        report.write("      datasets: [\n")
        i = 0
        for cfg, rbenchs in rel.items():
            for name, vals in rbenchs.items():
                report.write("        {\n")
                report.write("          label: \"{}\",\n".format(cfg + " : " + name))
                report.write("          borderColor: \"{}\",\n".format(colors[i % len(colors)]))
                report.write("          pointRadius: 6,\n")
                report.write("          pointHoverRadius: 7,\n")
                report.write("          fill: false,\n")
                report.write("          lineTension: 0.1,\n")
                report.write("          data: [{}],\n".format(', '.join(vals)))
                report.write("        },\n")
                i += 1
        report.write("      ],\n")
        report.write("    }\n")
        report.write("    var {0} = document.getElementById(\"{0}\").getContext(\"2d\");\n".format(chart_name))
        report.write("    new Chart({}, {{\n".format(chart_name))
        report.write("      type: 'line',\n")
        report.write("      data: changeData{},\n".format(chart_name))
        report.write("      options: {\n")
        report.write("        responsive: true,\n")
        report.write("        legend: { display: false },\n")
        report.write("        scales: {\n")
        report.write("          xAxes: [{ display: false }],\n")
        report.write("          yAxes: [{ ticks: { suggestedMin: 0.9, suggestedMax: 1.1 } }],\n")
        report.write("        },\n")
        report.write("        maintainAspectRatio: false,\n")
        report.write("      },\n")
        report.write("    })\n")
        report.write("    </script>\n")
        report.write("    </td>\n")
        report.write("  </tr>\n")

    report.write("</table>\n")
    write_html_footer(report)

for test in tests:
    with open('reports/' + test + '.html', 'w') as report:
        write_html_header(report)

        report.write("<script src=\"https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.8.0/Chart.min.js\"></script>\n")
        report.write("<script type=\"text/javascript\">\n")
        report.write("Chart.defaults.global.defaultFontFamily = 'Helvetica';\n")
        report.write("Chart.defaults.global.defaultFontSize = 16;\n")

        for bench in benchs:
            cfgdata = {}
            for cfg in cfgs:
                # collect the benchmark results
                tbenchs = {}
                for date in sorted(results.keys()):
                    if date in results and test in results[date] and cfg in results[date][test]:
                        res = results[date][test][cfg]
                        if bench in res.perfs:
                            perf = res.perfs[bench]
                            tbenchs[date] = perf.time
                # if none are part of this test, stop
                if len(tbenchs) == 0:
                    cfgdata[cfg] = []
                # otherwise put them into cfgdata and fill up missing results with 0
                else:
                    data = []
                    for date in sorted(results.keys()):
                        if date in tbenchs:
                            data.append(str(tbenchs[date]))
                        else:
                            data.append("null")
                    cfgdata[cfg] = data

            # skip benchmarks that are not part of this test
            if sum(len(cfgdata[item]) for item in cfgdata) == 0:
                continue

            chart_name = re.sub(r'[^a-zA-Z0-9_]', '', bench)
            report.write("var benchData{} = {{\n".format(chart_name))
            report.write("  labels: [")
            for date in sorted(results.keys()):
                report.write("\"{}\", ".format(date))
            report.write("  ],\n")
            report.write("  datasets: [\n")
            i = 0
            for cfg in cfgs:
                report.write("    {\n")
                report.write("      label: \"{}\",\n".format(cfg))
                report.write("      borderColor: \"{}\",\n".format(colors[i % len(colors)]))
                report.write("      pointRadius: 6,\n")
                report.write("      pointHoverRadius: 7,\n")
                report.write("      lineTension: 0.1,\n")
                report.write("      fill: false,\n")
                report.write("      data: [{}],\n".format(', '.join(cfgdata[cfg])))
                report.write("    },\n")
                i += 1
            report.write("  ],\n")
            report.write("}\n")
            report.write("</script>\n")

            report.write("<h2>{}</h2>\n".format(bench))
            report.write("<div style=\"width: 60%;\">\n")
            report.write("  <canvas id=\"chart_{}\"></canvas>\n".format(chart_name))
            report.write("</div>\n")
            report.write("<script type=\"text/javascript\">\n")
            report.write("var {0} = document.getElementById(\"chart_{0}\").getContext(\"2d\");\n".format(chart_name))
            report.write("new Chart({}, {{\n".format(chart_name))
            report.write("  type: 'line',\n")
            report.write("  data: benchData{},\n".format(chart_name))
            report.write("  options: {\n")
            report.write("    responsive: true,\n")
            report.write("    legend: {\n")
            report.write("      position: 'top',\n")
            report.write("    },\n")
            report.write("  },\n")
            report.write("})\n")

        report.write("</script>\n")
        write_html_footer(report)
