# ELMO - Electronic Movers | Production Support Simulation

ELMO (Electronic Movers) is a real-time Production Support simulation project designed to demonstrate how an IT support/production support team can automate file movement, monitor systems, track transfer status, handle failures, retry failed transfers, create incidents, monitor SLAs, and document resolution.

The project uses two Linux servers: a source server and a destination server. Files placed in the source `incoming` directory are detected automatically and transferred to the destination server using SCP. Transfer activity is tracked in MySQL and monitored through Prometheus and Grafana. ServiceNow is used to demonstrate the incident management lifecycle.

## Project Objectives

- Automate real-time file transfer between Linux servers
- Monitor transfer success and failure
- Track transfer status in MySQL
- Handle failed transfers and retry them
- Create and manage production-support incidents
- Monitor server health using Prometheus and Grafana
- Configure alerts for failed transfers
- Demonstrate SLA tracking
- Practice ServiceNow incident management
- Use Git and GitHub for version control
- Simulate an L1/L2 Production Support workflow

## Architecture

```text
                    ELMO Production Support Flow

        SOURCE SERVER
        /opt/elmo/incoming
                 |
                 v
        Inotify Real-Time Watcher
                 |
                 v
          Transfer Script
                 |
                 v
          SCP / SSH Transfer
                 |
                 v
        DESTINATION SERVER
        /opt/elmo/processed
                 |
                 v
          MySQL Tracking
                 |
        +--------+---------+
        |                  |
        v                  v
 Prometheus/Grafana    Failure Handling
        |                  |
        v                  v
 Monitoring & Alerts   Retry Mechanism
                           |
                           v
                    Incident Management
                           |
                           v
                       ServiceNow
                           |
                           v
                 Investigation / RCA
                           |
                           v
                    Resolve / Close
```

## Environment

| Component | Details |
|---|---|
| Source OS | Ubuntu Server |
| Destination OS | Ubuntu Server |
| Source IP | `192.168.56.101` |
| Destination IP | `192.168.56.102` |
| File Transfer | SCP over SSH |
| Automation | Bash Shell Scripting |
| Real-Time Detection | inotify |
| Database | MySQL 8.4 |
| Monitoring | Prometheus |
| Visualization | Grafana |
| Incident Management | ServiceNow |
| Version Control | Git / GitHub |
| Virtualization | VirtualBox |

## ELMO Directory Structure

```text
/opt/elmo/
├── incoming/          # Files waiting for transfer
├── processed/         # Successfully transferred files
├── failed/            # Failed files
├── logs/              # Application and transfer logs
├── incidents/         # Local incident records
├── elmo_watcher.sh    # Real-time file watcher
├── transfer_file.sh   # File transfer and status handling
├── db_start.sh        # Creates STARTED transfer record
├── db_success.sh      # Updates successful transfer
├── retry_failed.sh    # Retries failed transfers
├── check_incidents.sh # Checks failed transfers and creates incidents
└── README.md
```

## Real-Time File Transfer

The ELMO watcher uses `inotifywait` to continuously monitor the source `incoming` directory.

When a new file is written or moved into the directory:

1. The watcher detects the file.
2. `transfer_file.sh` is executed.
3. A `STARTED` record is inserted into MySQL.
4. SCP transfers the file to the destination server.
5. A successful transfer is marked `SUCCESS`.
6. The source file is removed after successful transfer.
7. If SCP fails, the record is marked `FAILED`.
8. The failed file is moved to the `failed` directory.

## Database Tracking

The project uses a MySQL database named `elmo`.

### Table

```sql
CREATE TABLE file_transfer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    file_name VARCHAR(255),
    status VARCHAR(20),
    start_time DATETIME,
    end_time DATETIME,
    retry_count INT DEFAULT 0,
    error_message VARCHAR(500)
);
```

### Example Status Flow

```text
STARTED
   |
   +----> SUCCESS
   |
   +----> FAILED
             |
             v
           RETRY
             |
             v
           SUCCESS
```

The database provides a central record of file-transfer activity for monitoring and troubleshooting.

## Failure Handling and Retry

ELMO was tested with simulated SSH connectivity failures.

When the destination server cannot be reached:

- SCP fails
- The transfer is marked `FAILED`
- An error is recorded
- The file is moved to `/opt/elmo/failed/`
- The failed transfer can be retried after connectivity is restored

The retry mechanism updates the transfer tracking information and allows failed files to be delivered without manually recreating the transfer.

## Incident Management

ELMO includes an incident workflow for production-support scenarios.

The project checks the number of failed transfers and can create a local incident record containing:

- Incident ID
- Status
- Priority
- Failed transfer count
- Creation time
- Root cause
- Impact
- Resolution
- Preventive action

### Example RCA

```text
Root Cause:
SCP/SSH transfer failure.

Impact:
Files were not delivered to the destination server.

Resolution:
Connectivity was restored and failed transfers were retried.

Preventive Action:
Grafana monitoring, automatic alerts, and retry mechanisms were enabled.
```

## ServiceNow Integration / Workflow Demonstration

A ServiceNow Personal Developer Instance was used to demonstrate the ELMO production-support incident lifecycle.

Example incident:

```text
INC0010001
```

Scenario:

```text
ELMO file transfer failure
        ↓
Incident created in ServiceNow
        ↓
Impact / Urgency assigned
        ↓
Assignment Group: Service Desk
        ↓
Investigation documented in Work Notes
        ↓
Connectivity restored
        ↓
File transfer retried successfully
        ↓
Resolution code selected
        ↓
Incident Resolved
        ↓
Incident Closed
```

This demonstrates practical incident-management activities such as ticket creation, prioritization, assignment, investigation, work notes, resolution, and closure.

## Monitoring

Prometheus and Grafana are used to monitor the ELMO environment.

### Prometheus Metrics

The project monitors:

- CPU utilization
- Memory utilization
- Disk utilization
- Network traffic
- Linux server health

Node Exporter provides the Linux system metrics to Prometheus.

## Grafana Dashboard

The ELMO Production Monitoring dashboard contains:

1. CPU utilization
2. RAM utilization
3. Disk utilization
4. Network receive traffic
5. MySQL transfer status
6. SLA status

### MySQL Transfer Status

The dashboard displays transfer states such as:

```text
SUCCESS
FAILED
STARTED
```

### SLA Monitoring

ELMO uses a five-minute transfer target for SLA demonstration.

Successful transfers completed within five minutes are shown as:

```text
SLA MET
```

Successful transfers exceeding five minutes can be identified as:

```text
SLA BREACHED
```

Failed transfers are shown separately.

## Grafana Alerting

A Grafana alert was configured for failed transfers.

Example condition:

```sql
SELECT COUNT(*) AS failed_count
FROM file_transfer
WHERE status = 'FAILED';
```

The alert is triggered when the failed-transfer count exceeds the configured threshold.

This simulates a production monitoring workflow where support teams receive alerts when file-transfer failures occur.

## Testing Performed

The project was tested for:

- Successful file transfer
- Real-time file detection
- SCP connectivity
- MySQL status recording
- SSH connectivity failure
- Failed-file handling
- Retry of failed transfers
- Incident creation
- Incident lifecycle
- Root-cause documentation
- Grafana monitoring
- Grafana failed-transfer alert
- SLA monitoring
- Final end-to-end file transfer

### Final End-to-End Test

A test file was created in:

```text
/opt/elmo/incoming/final_test.txt
```

The file was automatically detected and transferred to:

```text
/opt/elmo/processed/final_test.txt
```

The transfer was also recorded in MySQL.

This confirmed that the core ELMO workflow was operating successfully.

## Version Control

The project is maintained using Git and GitHub.

Runtime directories are excluded from version control using `.gitignore`:

```text
incidents/
incoming/
logs/
```

This prevents temporary files, runtime logs, and incident records from being unnecessarily committed to the repository.

## Production Support Skills Demonstrated

This project demonstrates practical experience with:

- Linux administration
- Bash/Shell scripting
- File transfer automation
- SSH/SCP
- Real-time monitoring with inotify
- MySQL
- SQL troubleshooting
- Prometheus
- Grafana
- Monitoring dashboards
- Alerting
- SLA monitoring
- Incident management
- ServiceNow
- Root Cause Analysis
- Failure handling
- Retry mechanisms
- Log analysis
- L1/L2 troubleshooting
- Git and GitHub
- Production support workflow

## Key Troubleshooting Scenarios

### Scenario 1 - File Transfer Failure

**Problem:** File was not delivered to the destination server.

**Investigation:**
- Checked transfer logs
- Checked SCP/SSH connectivity
- Checked MySQL transfer status

**Resolution:**
- Restored connectivity
- Retried the failed transfer
- Confirmed delivery on the destination server

### Scenario 2 - Failed Transfer Monitoring

**Problem:** Multiple transfers entered `FAILED` status.

**Investigation:**
- Checked MySQL records
- Checked Grafana dashboard
- Reviewed transfer logs

**Resolution:**
- Restored transfer connectivity
- Retried failed files
- Verified successful delivery

## Project Outcome

ELMO provides a practical simulation of a Production Support environment where automated file processing is combined with monitoring, database tracking, alerting, incident management, troubleshooting, RCA, and service restoration.

The project demonstrates how an L1/L2 support engineer can monitor an application workflow, investigate failures, coordinate resolution, document incidents, and verify service recovery.

## Author

**Smruti Ranjan Swain**

B.Tech - Electronics & Communication Engineering

Interested in:

- Production Support
- Application Support
- Technical Support
- IT Support
- Service Desk
- L1/L2 Support
- Linux Support
- Incident Management
