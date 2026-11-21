# BidNile notes

## 1. The four schemas

- `Membership` has `Country`, `City`, `Member`, and `Wallet`. I put member accounts, where people live, and their wallet balances together.
- `Operations` has `Employee` and `Warehouse`. These tables cover where employees work and who manages each warehouse.
- `Catalog` has `Category`, `Item`, and `ItemPhoto`. These tables describe what members list for sale.
- `Sales` started with `Auction`, `AuctionMember`, and `Bid`. These tables cover the auction itself, who follows it, and who bids. In Task 3.12, I moved `AuctionMember` to the new `Marketing` schema because Marketing now handles auction follows.

## 2. Relationships

- **One to one.** A wallet uses `MemberId` as both its primary key and a foreign key to `Member`. Each wallet belongs to one member, and the key lets a member have at most one wallet.
- **One to many.** A country can have many cities. I put `CountryCode` on `City` as a foreign key to `Country`.
- **Many to many.** A member can follow several auctions, and an auction can have several followers. I used `AuctionMember` with foreign keys to both tables. Its primary key is `(AuctionId, MemberId)`, so the same member can follow an auction only once.
- **Recursive.** A member can invite another member. I made `InvitedByMemberId` a nullable foreign key back to `Member.MemberId`. Categories also use a self-reference through `ParentCategory`.
- **Circular.** `Employee.WarehouseId` points to the employee's warehouse. `Warehouse.ManageMemberId` points back to the employee who manages it. I made `ManageMemberId` unique so an employee can manage at most one warehouse.
- **Weak entity.** An item photo belongs to an item. I used `(ItemId, Position)` as the photo's primary key. The `ItemId` foreign key also uses `ON DELETE CASCADE` to delete the photos when their item is deleted.

## 3. Why I used these data types

- `UNIQUEIDENTIFIER` for members lets the phone app generate a member ID before sending it to the server. When the app leaves it out, SQL Server can provide one with `NEWID()`.
- `BIGINT` for bid IDs gives the counter room to go past the roughly 2.1 billion positive values an `INT` can hold.
- `FLOAT` works for latitude and longitude because GPS coordinates are approximate measurements. I used `DECIMAL(12,2)` for money so two decimal places are stored exactly.
- `DATETIMEOFFSET(3)` keeps the auction's start or end time together with its UTC offset. For example, I can tell whether a time was entered with `+02:00` or `+04:00`.

## 4. Why I added the circular foreign keys later

If I create `Employee` first, `Warehouse` does not exist yet. If I create `Warehouse` first, there is no `Employee` table for the manager reference. I created both tables with their foreign-key columns first, then added the constraints with `ALTER TABLE` in Task 3.1.

## 5. The order I filled the tables

Countries went in before cities, members before wallets, and parent categories before subcategories. The members who sent invitations also went in before the members who used them.

For the first warehouse, I temporarily let `Employee.WarehouseId` accept `NULL`. I added the manager as an employee, created the warehouse with that manager, filled in the employee's warehouse, and changed the column back to `NOT NULL`. For the remaining warehouses, the new managers started at an existing warehouse and moved to their own warehouses after those rows were created.

Items went in after their sellers, inspectors, categories, and warehouses were available. Then came item photos, auctions, bids, and auction follows. The order mattered because the foreign keys require the referenced rows to exist before their IDs can be used.

I set up the database, tables, and constraints myself and entered the first sample rows in SSMS. I used ChatGPT to fill in the column values for the remaining sample rows through **Edit Top 200 Rows**.

## 6. The errors in Tasks 3.6 and 3.11

- **Task 3.6.** The check constraint `CK_Warehouse_MaxItems` depended on `MaxItems`, so I had to drop the check before changing the column type. I changed the column to `SMALLINT NOT NULL`, then added the check back with `MaxItems > 0 AND MaxItems <= 30000`.
- **Task 3.11.** SQL Server would not let me drop `IsVerified` while `DF_Member_IsVerified` was still attached to it. I added nullable `VerifiedAt`, dropped that default constraint, and then dropped `IsVerified`.

## 7. Task 5 hand trace

I started with `[1, 2, 3, 4]`. The prefix is the product of the numbers before the current index, and the suffix is the product of the numbers after it. I used `1` whenever a side was empty.

- Index 0, value 1. Prefix is `1`. Suffix is `2 * 3 * 4 = 24`. This gives `24`.
- Index 1, value 2. Prefix is `1`. Suffix is `3 * 4 = 12`. This gives `12`.
- Index 2, value 3. Prefix is `1 * 2 = 2`. Suffix is `4`. This gives `8`.
- Index 3, value 4. Prefix is `1 * 2 * 3 = 6`. Suffix is `1`. This gives `6`.

My final array is `[24, 12, 8, 6]`.
