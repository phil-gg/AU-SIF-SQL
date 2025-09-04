# Explanation of files in this folder 

 -  **"Drop-then-Create-SIF-tables.sql"** is the most important file in this
    folder.  This is the target SIF data structure, with a complete set of
    relational (PK, FK) and uniqueness constraints.
 -  **"Edited-DDL-for-SIF-AU-v3.6.3.sql"** is a set of tables without constraints
    auto-generated from the SIF XML specification.  Tables have been copied from
    here, then modified to accelerate the build of Drop-then-Create-SIF-tables.sql
 -  **"cdm_demo_gold-local-db-setup.sql"** is a short script to set up a local
    Microsoft SQL Server instance with suitable database and permissions to host
    and run Drop-then-Create-SIF-tables.sql
 -  *"Aborted-Conditional-Logic-for-Synapse-Analytics.sql"* attempted to build
    tables without constraints on Synapse, but tables with constraints on other
    database engines.  This proved too laborious and slow, and is depreciated.

# Completed SIF sections

| Phase | Section ID <br> range From  | Section ID <br> range To  | Sif Area |
|-------:|-------:|--------:|:---|
|  **1** | 3.10.1 | 3.10.11 | [SIF AU Student Baseline Profile (SBP) and supporting   objects](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.10%20sif%20au%20student%20baseline%20profile%20(sbp)%20and%20supporting%20objects) |
|  **2** |  3.6.6 |   3.6.6 | [Classroom Assessment >   TermInfo](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.6.5%20StudentScoreJudgementAgainstStandard-,3.6.6%20terminfo,-3.7%20Finance) |
|  **2** |  3.8.1 |   3.8.2 | [Learning Standards > LearningResourcePackage &   LearningResource](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.8%20learning%20standards) |
|  **2** | 3.11.1 | 3.11.13 | [Timetabling and Resource   Scheduling](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.11%20timetabling%20and%20resource%20scheduling) |

# Outstanding SIF sections

| Phase | Section ID <br> range From  | Section ID <br> range To  | Sif Area |
|-------:|-------:|--------:|:---|
|  **3** |  3.6.1 |   3.6.5 | [Classroom   Assessment](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.6%20classroom%20assessment) |
|  **3** |  3.8.3 |   3.8.4 | [Learning   Standards](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.8%20learning%20standards) |
|  **4** | 3.12.1 |  3.12.8 | [Wellbeing](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.11.13%20TimeTableSubject-,3.12%20wellbeing,-3.12.1%20PersonalisedPlan) |
|  **5** |  3.2.1 |   3.2.5 | [Activity](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=Code%20Set%20Validation-,3.2%20activity,-3.2.1%20Activity) |
|  **6** |  3.4.1 |   3.4.7 | [Attendance](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.3.3%20AggregateStatisticInfo-,3.4%20attendance,-3.4.1%20CalendarDate) |
|  **7** |  3.9.1 |   3.9.9 | [NAPLAN](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.8.4%20LearningStandardItem-,3.9%20naplan,-3.9.1%20NAPCodeFrame) |
|  **8** |  3.7.1 |   3.7.8 | [Finance](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.6.6%20TermInfo-,3.7%20finance,-3.7.1%20ChargedLocationInfo) |
|  **9** |  3.3.1 |   3.3.3 | [Aggregated   Statistics](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.3%20aggregated%20statistics) |
| **10** |  3.5.1 |   3.5.8 | [Australian Government   Collections](http://specification.sifassociation.org/Implementation/AU/3.6.3/#:~:text=3.5%20australian%20government%20collections) |
