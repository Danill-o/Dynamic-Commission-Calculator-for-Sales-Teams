# Dynamic-Commission-Calculator-for-Sales-Teams


Project: Dynamic Commission Calculator for Sales Teams

Student: Ishimwe Daniel 

ID: 27296

Course: Database Development with PL/SQL (INSY 8311)

Institution: Adventist University of Central Africa (AUCA)

Lecturer: Eric Maniraguha

Completion Date: December 8, 2025

Project Type: Capstone Project (Final Exam)

➢ Introduction 

The Dynamic Commission Calculator for Sales Teams is a system designed to automate, streamline, and enhance how sales commissions are calculated within an organisation.  Traditionally, many companies rely on manual spreadsheets and fixed percentage rules,  
which are time-consuming, error-prone, and difficult to update when sales policies change. This project solves these challenges by building a flexible PL/SQL-based solution that automatically computes commissions based on sales performance, product  categories, sales targets, and personalised business rules. 
The system ensures accuracy, fairness, and transparency between management and sales teams. It also improves productivity by reducing administrative workload and providing immediate feedback on sales performance. The project is suitable for companies with varying commission structures, including tiered schemes, product-specific percentages, or incentive bonuses. 

🎯 Problem Statement

Sales organizations struggle with manual, error-prone commission calculations that lack real-time processing, dynamic rule application, and comprehensive analytics. This system automates commission calculations with business intelligence capabilities to solve:

 	Manual calculation errors and delays

 	Lack of real-time commission processing

 	Inconsistent application of commission rules


 	Limited analytics for decision-making

 	No comprehensive audit trail


  ➢ Entities and relationship  

  <img width="574" height="327" alt="image" src="https://github.com/user-attachments/assets/52eb0bd0-5168-470b-a35e-fc0d22910372" />

 RELATIONSHIPS IN THE DIAGRAM

1. DEPARTMENT → SALES_REP

Relationship:

•	DEPARTMENT (1)——(∞) SALES_REP

FK:

•	SALES_REP.dept_id → DEPARTMENT.dept_id

Meaning:

Each department has many sales reps; every sales rep belongs to one department.

2. REGION → SALES_REP
   
Relationship:

•	REGION (1)——(∞) SALES_REP

FK:

•	SALES_REP.region_id → REGION.region_id

Meaning:

Each region has many sales reps; every rep belongs to one region.

3. REGION → HOLIDAY
   
Relationship:

•	REGION (1)——(∞) HOLIDAY

FK:

•	HOLIDAY.region_id → REGION.region_id

Meaning:

Every holiday is defined for one region; each region can have many holidays.

4. PRODUCT → SALE
   
Relationship:

•	PRODUCT (1)——(∞) SALE

FK:

•	SALE.product_id → PRODUCT.product_id

Meaning:

A sale references one product; each product can be sold many times.

5. SALES_REP → SALE
   
Relationship:

•	SALES_REP (1)——(∞) SALE

FK:

•	SALE.rep_id → SALES_REP.rep_id

Meaning:

Each sale is performed by one sales rep; a rep can have many sales.

6. COMMISSION_RULE → COMMISSION_CALCULATION
   
Relationship:

•	COMMISSION_RULE (1)——(∞) COMMISSION_CALCULATION

FK:

•	COMMISSION_CALCULATION.rule_id → COMMISSION_RULE.rule_id

Meaning:

A commission rule is applied many times in commission calculations.

7. SALE → COMMISSION_CALCULATION
    
Relationship:

•	SALE (1)——(1) COMMISSION_CALCULATION
FK:
•	COMMISSION_CALCULATION.sale_id → SALE.sale_id

Meaning:
Each sale generates one commission calculation.

8. COMMISSION_CALCULATION → PAYOUT
   
Relationship:

•	COMMISSION_CALCULATION (1)——(∞) PAYOUT

FK:

•	PAYOUT.calc_id → COMMISSION_CALCULATION.calc_id

Meaning:

A commission calculation can result in multiple payouts (e.g., split payments).

9. SALE → AUDIT_LOG
    
Relationship:

•	SALE (1)——(∞) AUDIT_LOG

FK:

•	AUDIT_LOG.sale_id → SALE.sale_id

Meaning:

A sale may appear in audit logs multiple times (eg. updates, corrections).


	Process Overview

The Dynamic Commission Calculator automates the end-to-end workflow of sales commission processing, from transaction recording through payment disbursement, with built-in approval workflows and comprehensive auditing.

	Main Components

1. Transaction Recording & Validation

	Actors: Sales Representatives, System

	Flow: Sales reps record transactions in real-time through the system interface. The system validates data against business rules (customer validation, product codes, pricing limits) and stores valid transactions in the database with complete audit trails.

2. Commission Calculation Engine

	Actors: System (Automated)

	Flow: Upon transaction validation, the system retrieves applicable commission rules based on product category, sales territory, and representative tier. It calculates base commission, applies performance multipliers, checks target achievement for bonuses, and generates preliminary commission records. Calculations consider factors like: base rate (%), tier multiplier (bronze/silver/gold/platinum), target achievement bonus, product-specific rates, and team vs. individual sales split.

3. Approval Workflow


	Actors: System, Sales Managers, Finance Department

	Flow: Commissions below a threshold (e.g., $5,000) are auto-approved. Higher amounts require manager approval. Managers review commission details, sales documentation, and performance metrics. They can approve, reject with feedback, or escalate to finance for complex cases. Rejected commissions return to sales reps for clarification.

4. Payment Processing

	Actors: Finance Department, System

	Flow: Approved commissions are batched by pay period (weekly/biweekly/monthly). Finance validates total amounts against budgets, processes batch payments through the payroll system, updates payment status, and generates financial reports for accounting reconciliation.

5. Dispute Resolution

	Actors: Sales Representatives, Sales Managers, Finance

	Flow: Sales reps can dispute commission calculations within 30 days. The system flags disputed records, managers investigate by reviewing transaction history and rule application, and resolutions result in either recalculation or dispute closure with documentation.

<img width="569" height="365" alt="image" src="https://github.com/user-attachments/assets/a0280fe6-b376-4df8-bad0-68f00a041087" />


Phase IV: Database Creation 

Objective: Create and configure Oracle pluggable database

Deliverable: Database creation scripts + configuration

Key Components:

•	Database: mon_27296_daniel_DynamicCommissionCalculator_db

<img width="465" height="350" alt="image" src="https://github.com/user-attachments/assets/ad1f0906-26e5-468f-a9d5-096ba17ad5a6" />

•	Tablespaces for data, indexes, and temp storage

<img width="435" height="208" alt="image" src="https://github.com/user-attachments/assets/fbc887c0-743b-4a9f-931b-d82d31fa09b7" />

•	Archive logging enabled

<img width="420" height="296" alt="image" src="https://github.com/user-attachments/assets/47df5259-be00-40de-860f-10e9b740bdc5" />

•	Memory parameters optimized

<img width="429" height="116" alt="image" src="https://github.com/user-attachments/assets/ee4f4ab8-0e93-4ef3-b817-3078f1afaa70" />

Phase V: Table Implementation & Data Insertion 

Objective: Build physical database structure with realistic test data

Deliverable: CREATE/INSERT scripts + validation queries

Key Components:
•	9 Main Tables:

1.	SALES_REP - Sales representative information


<img width="426" height="234" alt="image" src="https://github.com/user-attachments/assets/012b5932-574a-408e-82f1-04b21cc8aa42" />

2.	DEPARTMENT - Department data

<img width="392" height="166" alt="image" src="https://github.com/user-attachments/assets/c135b421-8817-4080-9cf5-465c689586c2" />


3.	REGION - Regional information

<img width="333" height="145" alt="image" src="https://github.com/user-attachments/assets/c46a812f-40de-4d89-93e6-05fbff87672c" />

4.	PRODUCT - Product catalog

<img width="418" height="144" alt="image" src="https://github.com/user-attachments/assets/100394c5-51b1-4af6-8c3e-906829ae6f77" />

5.	SALE - Sales transactions

<img width="499" height="200" alt="image" src="https://github.com/user-attachments/assets/65297016-ba09-4e9f-adeb-feae3242e089" />

6.	COMMISSION_RULE - Commission calculation rules

<img width="546" height="101" alt="image" src="https://github.com/user-attachments/assets/26d3d86c-01cb-488c-94fa-0cb16698e1c1" />

7.	COMMISSION_CALCULATION - Calculated commissions

<img width="662" height="242" alt="image" src="https://github.com/user-attachments/assets/a9b3f6de-2a03-4859-b51a-4b2df8df9593" />

8.	PAYOUT - Commission payout records

<img width="418" height="235" alt="image" src="https://github.com/user-attachments/assets/64cb13bf-ebf9-41cf-8db5-501c5a60a478" />

9.	AUDIT_LOG - Comprehensive audit trail

<img width="416" height="242" alt="image" src="https://github.com/user-attachments/assets/85f1a53b-ad49-4485-a979-f8b9733d173c" />

•	500+ realistic records across all tables

•	Constraints: PK, FK, CHECK, NOT NULL, UNIQUE, DEFAULT

•	Indexes for performance optimization

•	Sequences for ID generation

Phase VI: PL/SQL Development

Objective: Develop procedures, functions, packages, and cursors

Deliverable: PL/SQL scripts + test results

5 Core Procedures:

1.	calculate_sale_commission() - Calculate commission for individual sales
2.	process_monthly_payout() - Process bulk commission payments
3.	generate_sales_report() - Generate detailed sales reports
4.	bulk_update_product_prices() - Update prices with business rules
5.	update_rep_commission_rate() - Update commission rates with validation

   
5 Key Functions:


1.	get_tiered_commission_rate() - Determine rates based on sales tiers
2.	calculate_quarterly_bonus() - Calculate performance bonuses
3.	get_performance_rating() - Star ratings for sales reps (1-5 stars)
4.	check_promotion_eligibility() - Promotion eligibility checks
5.	validate_email() - Email format validation

   
Packages & Cursors:


•	COMMISSION_PKG package with specification and body
•	Explicit cursors for multi-row processing
•	Parameterized cursors for flexible queries
•	Window functions for advanced analytics


Phase VII: Advanced Programming & Auditing

Objective: Implement triggers, business rules, and comprehensive auditing

CRITICAL BUSINESS RULE:

Employee CANNOT INSERT/UPDATE/DELETE on:

1. WEEKDAYS (Monday-Friday)

2. PUBLIC HOLIDAYS (upcoming month only)
   
Implementation Components:

1.	Holiday Management System:
   
o	HOLIDAY table with recurring holidays

o	Sample holidays for upcoming month

2.	Enhanced Audit System:
   
o	Comprehensive AUDIT_LOG table with session/client info

o	Autonomous transaction logging function

3.	Restriction Functions:
   
o	is_weekday() - Check if date is Monday-Friday

o	is_holiday() - Check if date is public holiday

o	can_employee_perform_dml() - Enforce business rule

4.	Triggers:

o	4 Simple triggers for basic DML restriction

o	1 Compound trigger with comprehensive auditing

o	Business rule triggers for salary/commission validation

5.	Testing Requirements Met:

   
✅ Trigger blocks INSERT on weekday (DENIED)

✅ Trigger allows INSERT on weekend (ALLOWED)

✅ Trigger blocks INSERT on holiday (DENIED)

✅ Audit log captures all attempts

✅ Error messages are clear

✅ User info properly recorded


➢ Conclusion 

The Dynamic Commission Calculator is a robust, flexible, and innovative solution that significantly improves how sales commissions are determined and managed. By automating calculations, supporting multiple commission schemes, and providing clear analytical feedback, the system enhances fairness, transparency, and operational efficiency. It is designed with scalability in mind, allowing organisations to adapt the calculator as business needs evolve.















