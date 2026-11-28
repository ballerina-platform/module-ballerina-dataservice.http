// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/dataservice;
import ballerina/dataservice.http as dsHttp;
import ballerina/http;
import ballerina/time;

# A list of customers.
public type CustomerList record {
    # The customers
    Customer[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# The conditions that customers match, as the `filter` query parameter holds them.
public type CustomerFilter record {|
    # The conditions on the `id` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
    # The conditions on the `name` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} name?;
    # The conditions on the `email` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} email?;
    # The conditions on the `country` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} country?;
    # The conditions on the `tier` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} tier?;
|};

# A customer with the fields named in the `fields` query parameter.
public type CustomerPartial record {|
    # The `id` field of `Customer`
    int id;
    # The `name` field of `Customer`
    string name?;
    # The `email` field of `Customer`
    string email?;
    # The `country` field of `Customer`
    string country?;
    # The `tier` field of `Customer`
    int tier?;
    # The related sales orders, when `fields` names them
    SalesOrderRelatedPartialList orders?;
|};

# A list of customers with the fields named in the `fields` query parameter.
public type CustomerPartialList record {
    # The customers
    CustomerPartial[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# A customer read through a relation, with the fields named in the `fields` query parameter.
public type CustomerRelatedPartial record {|
    # The `id` field of `Customer`
    int id;
    # The `name` field of `Customer`
    string name?;
    # The `email` field of `Customer`
    string email?;
    # The `country` field of `Customer`
    string country?;
    # The `tier` field of `Customer`
    int tier?;
|};

# The fields of `Customer` that callers can see.
final readonly & dataservice:Field[] dataserviceCustomerFields = [
    {name: "id", column: "id", 'type: dataservice:INT, key: true},
    {name: "name", column: "name", 'type: dataservice:STRING},
    {name: "email", column: "email", 'type: dataservice:STRING},
    {name: "country", column: "country", 'type: dataservice:STRING},
    {name: "tier", column: "tier", 'type: dataservice:INT}
];

# The description of `Customer` that `ballerina/dataservice` builds queries from.
final dataservice:Entity dataserviceCustomerEntity = {
    name: "Customer",
    collection: "customers",
    'resource: "customers",
    datastore: dataservice:POSTGRESQL,
    fields: dataserviceCustomerFields,
    relations: [
        {
            'field: "orders",
            many: true,
            fields: ["id"],
            targetFields: ["customerId"],
            target: {
                name: "SalesOrder",
                collection: "salesOrders",
                'resource: "salesorders",
                datastore: dataservice:POSTGRESQL,
                fields: dataserviceSalesOrderFields
            }
        }
    ]
};

# The response to creating one customer.
public type CustomerCreated record {|
    *http:Created;
    # The created customer
    Customer body;
|};

# The response to creating several customers.
public type CustomerListCreated record {|
    *http:Created;
    # The created customers
    CustomerList body;
|};

# The JSON form of `SalesOrder`.
public type SalesOrderPayload record {|
    # The `id` field of `SalesOrder`
    readonly int id;
    # The `status` field of `SalesOrder`
    string status;
    # The `total` field of `SalesOrder`
    decimal total;
    # The `placedOn` field of `SalesOrder`, as an ISO 8601 date
    string placedOn;
    # The key of the related 'Customer'.
    int customerId;
|};

# The JSON form of `SalesOrderInsert`.
public type SalesOrderInsertPayload SalesOrderPayload;

# The JSON form of `SalesOrderUpdate`.
public type SalesOrderUpdatePayload record {|
    # The `status` field of `SalesOrderUpdate`
    string status?;
    # The `total` field of `SalesOrderUpdate`
    decimal total?;
    # The `placedOn` field of `SalesOrderUpdate`, as an ISO 8601 date
    string placedOn?;
    # The key of the related 'Customer'.
    int customerId?;
|};

# A list of sales orders.
public type SalesOrderList record {
    # The sales orders
    SalesOrderPayload[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# The conditions that sales orders match, as the `filter` query parameter holds them.
public type SalesOrderFilter record {|
    # The conditions on the `id` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
    # The conditions on the `status` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} status?;
    # The conditions on the `total` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} total?;
    # The conditions on the `placedOn` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
    |} placedOn?;
    # The conditions on the `customerId` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} customerId?;
|};

# A sales order with the fields named in the `fields` query parameter.
public type SalesOrderPartial record {|
    # The `id` field of `SalesOrder`
    int id;
    # The `status` field of `SalesOrder`
    string status?;
    # The `total` field of `SalesOrder`
    decimal total?;
    # The `placedOn` field of `SalesOrder`, as an ISO 8601 date
    string placedOn?;
    # The key of the related 'Customer'.
    int customerId?;
    # The related customer, when `fields` names it
    CustomerRelatedPartial? customer?;
    # The related order items, when `fields` names them
    OrderItemRelatedPartialList items?;
|};

# A list of sales orders with the fields named in the `fields` query parameter.
public type SalesOrderPartialList record {
    # The sales orders
    SalesOrderPartial[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# A sales order read through a relation, with the fields named in the `fields` query parameter.
public type SalesOrderRelatedPartial record {|
    # The `id` field of `SalesOrder`
    int id;
    # The `status` field of `SalesOrder`
    string status?;
    # The `total` field of `SalesOrder`
    decimal total?;
    # The `placedOn` field of `SalesOrder`, as an ISO 8601 date
    string placedOn?;
    # The key of the related 'Customer'.
    int customerId?;
|};

# The sales orders read through a relation, with the fields named in the `fields` query parameter.
public type SalesOrderRelatedPartialList record {
    # The sales orders, at most `dataserviceConfig.pageSize`
    SalesOrderRelatedPartial[] items;
    # Whether more sales orders exist
    boolean hasMore;
};

# The fields of `SalesOrder` that callers can see.
final readonly & dataservice:Field[] dataserviceSalesOrderFields = [
    {name: "id", column: "id", 'type: dataservice:INT, key: true},
    {name: "status", column: "status", 'type: dataservice:STRING},
    {name: "total", column: "total", 'type: dataservice:DECIMAL},
    {name: "placedOn", column: "placedOn", 'type: dataservice:DATE},
    {name: "customerId", column: "customerId", 'type: dataservice:INT}
];

# The description of `SalesOrder` that `ballerina/dataservice` builds queries from.
final dataservice:Entity dataserviceSalesOrderEntity = {
    name: "SalesOrder",
    collection: "salesOrders",
    'resource: "salesorders",
    datastore: dataservice:POSTGRESQL,
    fields: dataserviceSalesOrderFields,
    relations: [
        {
            'field: "customer",
            many: false,
            fields: ["customerId"],
            targetFields: ["id"],
            target: {
                name: "Customer",
                collection: "customers",
                'resource: "customers",
                datastore: dataservice:POSTGRESQL,
                fields: dataserviceCustomerFields
            }
        },
        {
            'field: "items",
            many: true,
            fields: ["id"],
            targetFields: ["salesorderId"],
            target: {
                name: "OrderItem",
                collection: "orderItems",
                'resource: "orderitems",
                datastore: dataservice:POSTGRESQL,
                fields: dataserviceOrderItemFields
            }
        }
    ]
};

# The response to creating one sales order.
public type SalesOrderCreated record {|
    *http:Created;
    # The created sales order
    SalesOrderPayload body;
|};

# The response to creating several sales orders.
public type SalesOrderListCreated record {|
    *http:Created;
    # The created sales orders
    SalesOrderList body;
|};

# Converts a `SalesOrder` to its JSON form.
#
# + value - The SalesOrder to convert
# + return - The JSON form
isolated function transformSalesOrderToPayload(SalesOrder value) returns SalesOrderPayload => {
    id: value.id,
    status: value.status,
    total: value.total,
    placedOn: dataservice:dateToString(value.placedOn),
    customerId: value.customerId
};

# Converts the JSON form of a `SalesOrderInsert` to the persist type.
#
# + payload - The JSON form to convert
# + return - The persist type, or `InvalidInput` when a value cannot be converted
isolated function transformPayloadToSalesOrderInsert(SalesOrderInsertPayload payload)
        returns SalesOrderInsert|dsHttp:InvalidInput {
    time:Date|dataservice:ConversionError placedOn = dataservice:dateFromString(payload.placedOn);
    if placedOn is dataservice:ConversionError {
        return dsHttp:toInvalidInput(placedOn, "SalesOrder", "placedOn");
    }
    return {id: payload.id, status: payload.status, total: payload.total, placedOn, customerId: payload.customerId};
}

# Converts the JSON form of a `SalesOrderUpdate` to the persist type.
#
# + payload - The JSON form to convert
# + return - The persist type, or `InvalidInput` when a value cannot be converted
isolated function transformPayloadToSalesOrderUpdate(SalesOrderUpdatePayload payload)
        returns SalesOrderUpdate|dsHttp:InvalidInput {
    SalesOrderUpdate value = {};
    string? status = payload?.status;
    if status !is () {
        value.status = status;
    }
    decimal? total = payload?.total;
    if total !is () {
        value.total = total;
    }
    string? placedOnText = payload?.placedOn;
    if placedOnText is string {
        time:Date|dataservice:ConversionError placedOn = dataservice:dateFromString(placedOnText);
        if placedOn is dataservice:ConversionError {
            return dsHttp:toInvalidInput(placedOn, "SalesOrder", "placedOn");
        }
        value.placedOn = placedOn;
    }
    int? customerId = payload?.customerId;
    if customerId !is () {
        value.customerId = customerId;
    }
    return value;
}

# A list of order items.
public type OrderItemList record {
    # The order items
    OrderItem[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# The conditions that order items match, as the `filter` query parameter holds them.
public type OrderItemFilter record {|
    # The conditions on the `id` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
    # The conditions on the `sku` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} sku?;
    # The conditions on the `quantity` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} quantity?;
    # The conditions on the `price` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} price?;
    # The conditions on the `salesorderId` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} salesorderId?;
    # The conditions on the `productId` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} productId?;
|};

# An order item with the fields named in the `fields` query parameter.
public type OrderItemPartial record {|
    # The `id` field of `OrderItem`
    int id;
    # The `sku` field of `OrderItem`
    string sku?;
    # The `quantity` field of `OrderItem`
    int quantity?;
    # The `price` field of `OrderItem`
    decimal price?;
    # The key of the related 'SalesOrder'.
    int salesorderId?;
    # The key of the related 'Product'.
    int productId?;
    # The related sales order, when `fields` names it
    SalesOrderRelatedPartial? salesOrder?;
    # The related product, when `fields` names it
    ProductRelatedPartial? product?;
|};

# A list of order items with the fields named in the `fields` query parameter.
public type OrderItemPartialList record {
    # The order items
    OrderItemPartial[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# An order item read through a relation, with the fields named in the `fields` query parameter.
public type OrderItemRelatedPartial record {|
    # The `id` field of `OrderItem`
    int id;
    # The `sku` field of `OrderItem`
    string sku?;
    # The `quantity` field of `OrderItem`
    int quantity?;
    # The `price` field of `OrderItem`
    decimal price?;
    # The key of the related 'SalesOrder'.
    int salesorderId?;
    # The key of the related 'Product'.
    int productId?;
|};

# The order items read through a relation, with the fields named in the `fields` query parameter.
public type OrderItemRelatedPartialList record {
    # The order items, at most `dataserviceConfig.pageSize`
    OrderItemRelatedPartial[] items;
    # Whether more order items exist
    boolean hasMore;
};

# The fields of `OrderItem` that callers can see.
final readonly & dataservice:Field[] dataserviceOrderItemFields = [
    {name: "id", column: "id", 'type: dataservice:INT, key: true},
    {name: "sku", column: "sku", 'type: dataservice:STRING},
    {name: "quantity", column: "quantity", 'type: dataservice:INT},
    {name: "price", column: "price", 'type: dataservice:DECIMAL},
    {name: "salesorderId", column: "salesorderId", 'type: dataservice:INT},
    {name: "productId", column: "productId", 'type: dataservice:INT}
];

# The description of `OrderItem` that `ballerina/dataservice` builds queries from.
final dataservice:Entity dataserviceOrderItemEntity = {
    name: "OrderItem",
    collection: "orderItems",
    'resource: "orderitems",
    datastore: dataservice:POSTGRESQL,
    fields: dataserviceOrderItemFields,
    relations: [
        {
            'field: "salesOrder",
            many: false,
            fields: ["salesorderId"],
            targetFields: ["id"],
            target: {
                name: "SalesOrder",
                collection: "salesOrders",
                'resource: "salesorders",
                datastore: dataservice:POSTGRESQL,
                fields: dataserviceSalesOrderFields
            }
        },
        {
            'field: "product",
            many: false,
            fields: ["productId"],
            targetFields: ["id"],
            target: {
                name: "Product",
                collection: "products",
                'resource: "products",
                datastore: dataservice:POSTGRESQL,
                fields: dataserviceProductFields
            }
        }
    ]
};

# The response to creating one order item.
public type OrderItemCreated record {|
    *http:Created;
    # The created order item
    OrderItem body;
|};

# The response to creating several order items.
public type OrderItemListCreated record {|
    *http:Created;
    # The created order items
    OrderItemList body;
|};

# A list of products.
public type ProductList record {
    # The products
    Product[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# The conditions that products match, as the `filter` query parameter holds them.
public type ProductFilter record {|
    # The conditions on the `id` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
    # The conditions on the `name` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} name?;
    # The conditions on the `description` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} description?;
    # The conditions on the `attr01` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr01?;
    # The conditions on the `attr02` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr02?;
    # The conditions on the `attr03` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr03?;
    # The conditions on the `attr04` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr04?;
    # The conditions on the `attr05` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr05?;
    # The conditions on the `attr06` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr06?;
    # The conditions on the `attr07` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr07?;
    # The conditions on the `attr08` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr08?;
    # The conditions on the `attr09` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr09?;
    # The conditions on the `attr10` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr10?;
    # The conditions on the `attr11` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr11?;
    # The conditions on the `attr12` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr12?;
    # The conditions on the `attr13` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr13?;
    # The conditions on the `attr14` field
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
        string contains?;
        string startsWith?;
    |} attr14?;
    # The conditions on the `num01` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num01?;
    # The conditions on the `num02` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num02?;
    # The conditions on the `num03` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num03?;
    # The conditions on the `num04` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num04?;
    # The conditions on the `num05` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num05?;
    # The conditions on the `num06` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num06?;
    # The conditions on the `num07` field
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num07?;
    # The conditions on the `dec01` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec01?;
    # The conditions on the `dec02` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec02?;
    # The conditions on the `dec03` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec03?;
    # The conditions on the `dec04` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec04?;
    # The conditions on the `dec05` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec05?;
    # The conditions on the `dec06` field
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec06?;
|};

# A product with the fields named in the `fields` query parameter.
public type ProductPartial record {|
    # The `id` field of `Product`
    int id;
    # The `name` field of `Product`
    string name?;
    # The `description` field of `Product`
    string description?;
    # The `attr01` field of `Product`
    string attr01?;
    # The `attr02` field of `Product`
    string attr02?;
    # The `attr03` field of `Product`
    string attr03?;
    # The `attr04` field of `Product`
    string attr04?;
    # The `attr05` field of `Product`
    string attr05?;
    # The `attr06` field of `Product`
    string attr06?;
    # The `attr07` field of `Product`
    string attr07?;
    # The `attr08` field of `Product`
    string attr08?;
    # The `attr09` field of `Product`
    string attr09?;
    # The `attr10` field of `Product`
    string attr10?;
    # The `attr11` field of `Product`
    string attr11?;
    # The `attr12` field of `Product`
    string attr12?;
    # The `attr13` field of `Product`
    string attr13?;
    # The `attr14` field of `Product`
    string attr14?;
    # The `num01` field of `Product`
    int num01?;
    # The `num02` field of `Product`
    int num02?;
    # The `num03` field of `Product`
    int num03?;
    # The `num04` field of `Product`
    int num04?;
    # The `num05` field of `Product`
    int num05?;
    # The `num06` field of `Product`
    int num06?;
    # The `num07` field of `Product`
    int num07?;
    # The `dec01` field of `Product`
    decimal dec01?;
    # The `dec02` field of `Product`
    decimal dec02?;
    # The `dec03` field of `Product`
    decimal dec03?;
    # The `dec04` field of `Product`
    decimal dec04?;
    # The `dec05` field of `Product`
    decimal dec05?;
    # The `dec06` field of `Product`
    decimal dec06?;
    # The related order items, when `fields` names them
    OrderItemRelatedPartialList orderItems?;
|};

# A list of products with the fields named in the `fields` query parameter.
public type ProductPartialList record {
    # The products
    ProductPartial[] items;
    # Whether records exist after this page
    boolean hasMore;
};

# A product read through a relation, with the fields named in the `fields` query parameter.
public type ProductRelatedPartial record {|
    # The `id` field of `Product`
    int id;
    # The `name` field of `Product`
    string name?;
    # The `description` field of `Product`
    string description?;
    # The `attr01` field of `Product`
    string attr01?;
    # The `attr02` field of `Product`
    string attr02?;
    # The `attr03` field of `Product`
    string attr03?;
    # The `attr04` field of `Product`
    string attr04?;
    # The `attr05` field of `Product`
    string attr05?;
    # The `attr06` field of `Product`
    string attr06?;
    # The `attr07` field of `Product`
    string attr07?;
    # The `attr08` field of `Product`
    string attr08?;
    # The `attr09` field of `Product`
    string attr09?;
    # The `attr10` field of `Product`
    string attr10?;
    # The `attr11` field of `Product`
    string attr11?;
    # The `attr12` field of `Product`
    string attr12?;
    # The `attr13` field of `Product`
    string attr13?;
    # The `attr14` field of `Product`
    string attr14?;
    # The `num01` field of `Product`
    int num01?;
    # The `num02` field of `Product`
    int num02?;
    # The `num03` field of `Product`
    int num03?;
    # The `num04` field of `Product`
    int num04?;
    # The `num05` field of `Product`
    int num05?;
    # The `num06` field of `Product`
    int num06?;
    # The `num07` field of `Product`
    int num07?;
    # The `dec01` field of `Product`
    decimal dec01?;
    # The `dec02` field of `Product`
    decimal dec02?;
    # The `dec03` field of `Product`
    decimal dec03?;
    # The `dec04` field of `Product`
    decimal dec04?;
    # The `dec05` field of `Product`
    decimal dec05?;
    # The `dec06` field of `Product`
    decimal dec06?;
|};

# The fields of `Product` that callers can see.
final readonly & dataservice:Field[] dataserviceProductFields = [
    {name: "id", column: "id", 'type: dataservice:INT, key: true},
    {name: "name", column: "name", 'type: dataservice:STRING},
    {name: "description", column: "description", 'type: dataservice:STRING},
    {name: "attr01", column: "attr01", 'type: dataservice:STRING},
    {name: "attr02", column: "attr02", 'type: dataservice:STRING},
    {name: "attr03", column: "attr03", 'type: dataservice:STRING},
    {name: "attr04", column: "attr04", 'type: dataservice:STRING},
    {name: "attr05", column: "attr05", 'type: dataservice:STRING},
    {name: "attr06", column: "attr06", 'type: dataservice:STRING},
    {name: "attr07", column: "attr07", 'type: dataservice:STRING},
    {name: "attr08", column: "attr08", 'type: dataservice:STRING},
    {name: "attr09", column: "attr09", 'type: dataservice:STRING},
    {name: "attr10", column: "attr10", 'type: dataservice:STRING},
    {name: "attr11", column: "attr11", 'type: dataservice:STRING},
    {name: "attr12", column: "attr12", 'type: dataservice:STRING},
    {name: "attr13", column: "attr13", 'type: dataservice:STRING},
    {name: "attr14", column: "attr14", 'type: dataservice:STRING},
    {name: "num01", column: "num01", 'type: dataservice:INT},
    {name: "num02", column: "num02", 'type: dataservice:INT},
    {name: "num03", column: "num03", 'type: dataservice:INT},
    {name: "num04", column: "num04", 'type: dataservice:INT},
    {name: "num05", column: "num05", 'type: dataservice:INT},
    {name: "num06", column: "num06", 'type: dataservice:INT},
    {name: "num07", column: "num07", 'type: dataservice:INT},
    {name: "dec01", column: "dec01", 'type: dataservice:DECIMAL},
    {name: "dec02", column: "dec02", 'type: dataservice:DECIMAL},
    {name: "dec03", column: "dec03", 'type: dataservice:DECIMAL},
    {name: "dec04", column: "dec04", 'type: dataservice:DECIMAL},
    {name: "dec05", column: "dec05", 'type: dataservice:DECIMAL},
    {name: "dec06", column: "dec06", 'type: dataservice:DECIMAL}
];

# The description of `Product` that `ballerina/dataservice` builds queries from.
final dataservice:Entity dataserviceProductEntity = {
    name: "Product",
    collection: "products",
    'resource: "products",
    datastore: dataservice:POSTGRESQL,
    fields: dataserviceProductFields,
    relations: [
        {
            'field: "orderItems",
            many: true,
            fields: ["id"],
            targetFields: ["productId"],
            target: {
                name: "OrderItem",
                collection: "orderItems",
                'resource: "orderitems",
                datastore: dataservice:POSTGRESQL,
                fields: dataserviceOrderItemFields
            }
        }
    ]
};

# The response to creating one product.
public type ProductCreated record {|
    *http:Created;
    # The created product
    Product body;
|};

# The response to creating several products.
public type ProductListCreated record {|
    *http:Created;
    # The created products
    ProductList body;
|};
