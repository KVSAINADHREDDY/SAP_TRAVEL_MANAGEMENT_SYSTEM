# Smart Travel Management System — SAP ABAP

A resume/portfolio project simulating a real travel booking platform, built end-to-end in SAP ABAP: custom data dictionary tables, four CRUD modules, and a joined reporting layer.

## Overview

This project models a simplified travel agency backend:

- **Customers** book trips to **Destinations**
- A **Booking** ties a customer, a destination, a travel date, and a traveler count together, and auto-calculates the total cost
- A **Payment** against a booking flips its status from `PENDING` to `CONFIRMED`
- **Reports** join across all four tables to produce readable, business-facing output (real names and cities instead of raw IDs)

Built as a self-directed learning project to demonstrate practical ABAP development: SE11 data modeling, Open SQL, ALV Grid display (`cl_salv_table`), field validation, auto-ID generation, and multi-table transaction logic — the kind of work expected in an entry-level SAP ABAP developer role.

## Tech / Concepts Demonstrated

- SE11 data dictionary design: domains, data elements, tables, foreign keys, currency/quantity field linking
- Open SQL: `SELECT SINGLE`, `SELECT ... INTO TABLE`, `SELECT COUNT(*)`, `SELECT SUM(...)`, inline declarations (`@DATA(...)`)
- ALV Grid output via `cl_salv_table`
- Auto-generated business keys (`BOOK######`, `PAY######`) using `SELECT MAX(...)` + offset arithmetic
- Defensive validation: existence checks, duplicate checks, status-based guard clauses, past-date checks
- Multi-table transactions (a single payment action updates two tables: `ZPAYMENT` insert + `ZBOOKING` update)
- Report-layer joins (loop-and-lookup pattern) turning technical IDs into business-readable output
- Revenue aggregation and sorting for a simple business-insight report

## Data Model

| Table | Purpose | Key Fields |
|---|---|---|
| `ZCUSTOMER_TABLE` | Customer master data | CUSTOMER_ID, CUST_NAME, MOBILE, EMAIL, PASSPORT_NO, NATIONALITY, ADDRESS |
| `ZDESTINATION` | Destination / package catalog | DEST_ID, COUNTRY, CITY, HOTEL, PACKAGE_PRICE, NUM_DAYS, CURRENCY |
| `ZBOOKING` | Booking transactions | BOOKING_ID, CUSTOMER_ID (FK), DEST_ID (FK), TRAVEL_DATE, NUM_TRAVELERS, TOTAL_AMOUNT, CURRENCY, BOOKING_STATUS, PAYMENT_STATUS |
| `ZPAYMENT` | Payment records | PAYMENT_ID, BOOKING_ID (FK), AMOUNT, CURRENCY, PAYMENT_MODE, PAYMENT_DATE, TXN_NUMBER, PAYMENT_STATUS |

Full ER diagram, DFD, and use-case matrix are in [`docs/01_Project_Documentation.pdf`](docs/01_Project_Documentation.pdf).

## Module Breakdown

| # | Module | Programs | Status |
|---|---|---|---|
| 1 | Customer Management | `ZCUST_CREATE`, `ZCUST_UPDATE`, `ZCUST_DELETE`, `ZCUST_SEARCH` | ✅ Complete |
| 2 | Destination Management | `ZDEST_CREATE`, `ZDEST_UPDATE`, `ZDEST_DELETE`, `ZDEST_SEARCH` | ✅ Complete |
| 3 | Booking Management | `ZBOOK_CREATE`, `ZBOOK_UPDATE`, `ZBOOK_CANCEL`, `ZBOOK_SEARCH` | ✅ Complete |
| 4 | Payment Management | `ZPAY_CREATE`, `ZPAY_SEARCH` | ✅ Complete |
| 5 | Reports | `ZRPT_BOOKING_SUMMARY`, `ZRPT_REVENUE_BY_DEST` | ✅ Complete |

### Key business logic

- **ZBOOK_CREATE** — validates customer & destination exist, blocks past travel dates, blocks duplicate bookings (same customer + destination + date, excluding cancelled ones), auto-generates `BOOKING_ID`, auto-calculates `TOTAL_AMOUNT = PACKAGE_PRICE × NUM_TRAVELERS`
- **ZBOOK_UPDATE** — lets a customer change travel date and/or traveler count *before* payment; blocked once `CONFIRMED` or `CANCELLED` to protect data/financial integrity; recalculates total on traveler-count change
- **ZBOOK_CANCEL** — guarded against double-cancelling or cancelling a paid booking
- **ZPAY_CREATE** — validates the booking, blocks payment on a cancelled/already-paid booking, checks amount matches the booking total, auto-generates `PAYMENT_ID`, and updates **two tables in one transaction**: inserts into `ZPAYMENT` and updates `ZBOOKING` to `CONFIRMED` / `PAID`
- **ZRPT_BOOKING_SUMMARY** — joins booking data with customer names and destination city/country for a fully readable summary
- **ZRPT_REVENUE_BY_DEST** — aggregates confirmed revenue and booking count per destination, sorted highest-earning first

## Repository Structure

```
├── docs/                          Full project documentation (proposal, SRS, ER diagram,
│                                   SE11 build guide, and one build guide per module)
├── src/
│   ├── 01_customer_management/
│   ├── 02_destination_management/
│   ├── 03_booking_management/
│   ├── 04_payment_management/
│   └── 05_reports/
└── README.md
```

## Known Limitations / Next Steps

- Foreign keys in SAP only validate on insert — `ZCUST_DELETE` and `ZDEST_DELETE` don't yet block deletion of a customer/destination that has active bookings. Planned fix: a `SELECT COUNT(*)` existence check against `ZBOOKING` before delete.
- ALV column headers for a couple of technical fields (e.g. `AMOUNT`, `PAYMENT_DATE`) can render with truncated labels due to auto-optimize column width — fixable with explicit `set_short_text`/`set_medium_text` calls.
- Reports use a LOOP + SELECT SINGLE lookup pattern rather than a single SQL JOIN. This was a deliberate readability choice for a project at this scale; a JOIN-based version is a natural next enhancement to demonstrate awareness of the N+1 SELECT problem.
- `ZPAY_CREATE` currently only supports full payment (amount must exactly match the booking total) — no partial/installment payment support yet.

## Author

Venkata Sainadh Reddy Kunduru — final-year B.Tech (AI & ML), SAP ABAP (ABAP Cloud) certified, Salesforce Agentforce Specialist & Trailhead Double Star Ranger.
