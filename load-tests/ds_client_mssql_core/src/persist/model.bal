import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

type Customer record {|
    readonly int id;
    string name;
    string email;
    string country;
    int tier;
    SalesOrder[] orders;
|};

type SalesOrder record {|
    readonly int id;
    string status;
    decimal total;
    time:Date placedOn;
    Customer customer;
    OrderItem[] items;
|};

type OrderItem record {|
    readonly int id;
    string sku;
    int quantity;
    decimal price;
    SalesOrder salesOrder;
    Product product;
|};

type Product record {|
    readonly int id;
    string name;
    @sql:Varchar {length: 1024}
    string description;
    string attr01;
    string attr02;
    string attr03;
    string attr04;
    string attr05;
    string attr06;
    string attr07;
    string attr08;
    string attr09;
    string attr10;
    string attr11;
    string attr12;
    string attr13;
    string attr14;
    int num01;
    int num02;
    int num03;
    int num04;
    int num05;
    int num06;
    int num07;
    decimal dec01;
    decimal dec02;
    decimal dec03;
    decimal dec04;
    decimal dec05;
    decimal dec06;
    OrderItem[] orderItems;
|};
