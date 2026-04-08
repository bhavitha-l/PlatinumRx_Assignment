# Spreadsheet Solutions

## 1. Populate ticket_created_at
Use:
=XLOOKUP(A2, ticket!E:E, ticket!B:B)

## 2. Same Day Tickets
=IF(DATE(created_at)=DATE(closed_at),1,0)

## 3. Same Hour Tickets
=IF(AND(INT(created_at)=INT(closed_at),
HOUR(created_at)=HOUR(closed_at)),1,0)

Use Pivot Table for aggregation.
