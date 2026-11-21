create database BidNile;
go

use BidNile;
go

create schema Membership;
go
create schema Operations;
go
create schema Catalog;
go
create schema Sales;
go

Create table Membership.Country
(
	CountryCode char(2) NOT NULL,
	NameEn varchar(60) not null,
	NameAr nvarchar(60) not null,
	PhoneCode varchar(5) not null,

	constraint PK_Country primary key (CountryCode)
);


create table Membership.City
(
	CityId INT identity not null,
	Name nvarchar(60) not null,
	CountryCode char(2) not null,

	constraint PK_City primary key (CityId),
	constraint UQ_City_CountryCode_Name unique (CountryCode, Name)
);
go

create table Membership.Member
(
	MemberId UNIQUEIDENTIFIER not null
		constraint DF_Member_MemberId default (NEWID()),
	CityId int not null,
	InvitedByMemberId UNIQUEIDENTIFIER null,
	FullName nvarchar(100) not null,
	Email nvarchar(254) not null,
	NationalIdOrPassport nvarchar(20) not null,
	BirthDate date not null,
	IsVerified BIT NOT NULL constraint DF_Member_IsVerified default (0),
	RegisteredAt datetime2(3) not null,
	Phone varchar(16) not null,

	constraint PK_Member primary key (MemberId),
	constraint UQ_Member_Email unique (Email),
	constraint UQ_Member_NationalIdOrPassport unique(NationalIdOrPassport),
	constraint CK_Member_BirthDate check (
    DATEADD(YEAR, 18, BirthDate) <= CAST(RegisteredAt AS DATE)
	),
);
go

create table Membership.Wallet
(
	MemberId UNIQUEIDENTIFIER  not null,
	Balance decimal(12,2) not null CONSTRAINT DF_Wallet_Balance DEFAULT (0),
	HeldAmount decimal(12,2) not null CONSTRAINT DF_Wallet_HeldAmount DEFAULT (0),
	CurrencyCode char(3) not null CONSTRAINT DF_Wallet_CurrencyCode DEFAULT ('EGP'),
	UpdatedAt datetime2(3) not null constraint DF_Wallet_UpdatedAt default (SYSUTCDATETIME()),

	constraint PK_Wallet primary key (MemberId),
	constraint CK_Wallet_Balance check (Balance >= 0),
	constraint CK_Wallet_HeldAmount check (HeldAmount >= 0 AND HeldAmount <= Balance)
);
go

create table Operations.Employee
(
	MemberId UNIQUEIDENTIFIER  not null,
	WarehouseId int not null,

	constraint PK_Employee primary key (MemberId)
);
go

create table Operations.Warehouse
(
	WarehouseId int identity not null,
	Name nvarchar(80) not null,
	Capacity int not null,
	Latitude float not null,
	Longitude float not null,
	CityId int not null,
	ManageMemberId uniqueidentifier not null,
	ManageStartDate date not null,

	constraint PK_Warehouse primary key (WarehouseId),
	constraint UQ_Warehouse_Name unique (Name),
	constraint CK_Warehouse_Capacity check (Capacity > 0),
	constraint CK_Warehouse_Latitude check (Latitude between -90 and 90),
	constraint CK_Warehouse_Longitude check (Longitude between -180 and 180),
	constraint UQ_Warehouse_ManageMemberId unique (ManageMemberId)
);
go

create table Catalog.Item
(
	ItemId int identity not null,
	Title nvarchar(150) not null,
	Description nvarchar(MAX),
	ConditionScore tinyint not null,
	Specification json not null,
	ListedAt datetime2(3) not null,
	WarehouseId int,
	InspectorMemberId uniqueidentifier,
	SellerMemberId uniqueidentifier not null,
	CategoryCode int not null,

	constraint PK_Items primary key (ItemId),
	constraint CK_Items_ConditionScore check (ConditionScore between 1 and 10),
    constraint CK_Item_InspectorMemberId check (
        InspectorMemberId IS NULL OR InspectorMemberId <> SellerMemberId
    )
);
go

create table Catalog.Category
(
	CategoryCode int not null,
	NameEn varchar(50) not null,
	NameAr nvarchar(50),
	CommissionPercentage decimal(4,2) not null,
	ParentCategory int,

	constraint PK_Category primary key (CategoryCode),
	constraint UK_Category_NameEn unique (NameEn),
	constraint CK_Category_CommissionPercentage check (CommissionPercentage between 0 and 30)
);
go

create table Catalog.ItemPhoto
(
    ItemId   int          NOT NULL,
    Position tinyint      NOT NULL
        constraint CK_ItemPhoto_Position check (Position BETWEEN 1 AND 20),
    PhotoUrl VARCHAR(500) NOT NULL,
    IsMain   BIT          NOT NULL
        constraint DF_ItemPhoto_IsMain default (0),

    constraint PK_ItemPhoto primary key (ItemId, Position)
);
go

create table Sales.Auction
(
	AuctionId int identity not null,
	StartingPrice decimal(12,2) not null,
	ReservePrice decimal(12,2),
	BidIncrement decimal(12,2) not null
		constraint DF_Auction_BidIncrement default (50.00),
	StartsAt datetimeoffset(3) not null,
	EndsAt datetimeoffset(3) not null,
	Status varchar(20) not null
		constraint DF_Auction_Status default ('Draft'),
	ItemId int not null,

	constraint PK_Auction primary key (AuctionId),
	constraint CK_Auction_StartingPrice check (StartingPrice > 0),
	constraint CK_Auction_ReservePrice check (
        ReservePrice IS NULL OR ReservePrice >= StartingPrice
    ),
	constraint CK_Auction_EndsAt check (EndsAt > StartsAt),
	constraint CK_Auction_Status check (Status in ('Draft', 'Live', 'Ended', 'Cancelled'))
);
go

create table Sales.AuctionMember
(
	AuctionId int not null,
	MemberId uniqueidentifier not null,
	FollowedAt datetime2(3) not null,

	constraint PK_AuctionMember primary key (AuctionId, MemberId)
);
go

create table Sales.Bid
(
	BidId bigint identity not null,
	Amount decimal(12,2) not null,
	PlacedAt datetime2(3) not null,
	IpAddress varchar(45) not null,
	AuctionId int not null,
	MemberId uniqueidentifier not null,

	constraint PK_Bid primary key (BidId),
	constraint CK_Bid_Amount check (Amount > 0),
	constraint UQ_Bid_AuctionId_Amount unique (AuctionId, Amount)
);
go


