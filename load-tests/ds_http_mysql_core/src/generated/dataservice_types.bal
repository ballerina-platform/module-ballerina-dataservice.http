// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/dataservice;
import ballerina/dataservice.http as dsHttp;
import ballerina/http;
import ballerina/time;

# A list of customers.
#
# + items - The customers
# + hasMore - Whether records exist after this page
public type CustomerList record {
    Customer[] items;
    boolean hasMore;
};

# The conditions that customers match, as the `filter` query parameter holds them.
#
# + id - The conditions on the `id` field
# + name - The conditions on the `name` field
# + email - The conditions on the `email` field
# + country - The conditions on the `country` field
# + tier - The conditions on the `tier` field
public type CustomerFilter record {|
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
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
#
# + id - The `id` field of `Customer`
# + name - The `name` field of `Customer`
# + email - The `email` field of `Customer`
# + country - The `country` field of `Customer`
# + tier - The `tier` field of `Customer`
# + orders - The related sales orders, when `fields` names them
public type CustomerPartial record {|
    int id;
    string name?;
    string email?;
    string country?;
    int tier?;
    SalesOrderRelatedPartialList orders?;
|};

# A list of customers with the fields named in the `fields` query parameter.
#
# + items - The customers
# + hasMore - Whether records exist after this page
public type CustomerPartialList record {
    CustomerPartial[] items;
    boolean hasMore;
};

# A customer read through a relation, with the fields named in the `fields` query parameter.
#
# + id - The `id` field of `Customer`
# + name - The `name` field of `Customer`
# + email - The `email` field of `Customer`
# + country - The `country` field of `Customer`
# + tier - The `tier` field of `Customer`
public type CustomerRelatedPartial record {|
    int id;
    string name?;
    string email?;
    string country?;
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
    datastore: dataservice:MYSQL,
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
                datastore: dataservice:MYSQL,
                fields: dataserviceSalesOrderFields
            }
        }
    ]
};

# The response to creating one customer.
#
# + body - The created customer
public type CustomerCreated record {|
    *http:Created;
    Customer body;
|};

# The response to creating several customers.
#
# + body - The created customers
public type CustomerListCreated record {|
    *http:Created;
    CustomerList body;
|};

# The JSON form of `SalesOrder`.
#
# + id - The `id` field of `SalesOrder`
# + status - The `status` field of `SalesOrder`
# + total - The `total` field of `SalesOrder`
# + placedOn - The `placedOn` field of `SalesOrder`, as an ISO 8601 date
# + customerId - The key of the related 'Customer'.
public type SalesOrderPayload record {|
    readonly int id;
    string status;
    decimal total;
    string placedOn;
    int customerId;
|};

# The JSON form of `SalesOrderInsert`.
public type SalesOrderInsertPayload SalesOrderPayload;

# The JSON form of `SalesOrderUpdate`.
#
# + status - The `status` field of `SalesOrderUpdate`
# + total - The `total` field of `SalesOrderUpdate`
# + placedOn - The `placedOn` field of `SalesOrderUpdate`, as an ISO 8601 date
# + customerId - The key of the related 'Customer'.
public type SalesOrderUpdatePayload record {|
    string status?;
    decimal total?;
    string placedOn?;
    int customerId?;
|};

# A list of sales orders.
#
# + items - The sales orders
# + hasMore - Whether records exist after this page
public type SalesOrderList record {
    SalesOrderPayload[] items;
    boolean hasMore;
};

# The conditions that sales orders match, as the `filter` query parameter holds them.
#
# + id - The conditions on the `id` field
# + status - The conditions on the `status` field
# + total - The conditions on the `total` field
# + placedOn - The conditions on the `placedOn` field
# + customerId - The conditions on the `customerId` field
public type SalesOrderFilter record {|
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
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
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} total?;
    record {|
        string eq?;
        string ne?;
        string lt?;
        string lte?;
        string gt?;
        string gte?;
        string[] anyOf?;
    |} placedOn?;
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
#
# + id - The `id` field of `SalesOrder`
# + status - The `status` field of `SalesOrder`
# + total - The `total` field of `SalesOrder`
# + placedOn - The `placedOn` field of `SalesOrder`, as an ISO 8601 date
# + customerId - The key of the related 'Customer'.
# + customer - The related customer, when `fields` names it
# + items - The related order items, when `fields` names them
public type SalesOrderPartial record {|
    int id;
    string status?;
    decimal total?;
    string placedOn?;
    int customerId?;
    CustomerRelatedPartial? customer?;
    OrderItemRelatedPartialList items?;
|};

# A list of sales orders with the fields named in the `fields` query parameter.
#
# + items - The sales orders
# + hasMore - Whether records exist after this page
public type SalesOrderPartialList record {
    SalesOrderPartial[] items;
    boolean hasMore;
};

# A sales order read through a relation, with the fields named in the `fields` query parameter.
#
# + id - The `id` field of `SalesOrder`
# + status - The `status` field of `SalesOrder`
# + total - The `total` field of `SalesOrder`
# + placedOn - The `placedOn` field of `SalesOrder`, as an ISO 8601 date
# + customerId - The key of the related 'Customer'.
public type SalesOrderRelatedPartial record {|
    int id;
    string status?;
    decimal total?;
    string placedOn?;
    int customerId?;
|};

# The sales orders read through a relation, with the fields named in the `fields` query parameter.
#
# + items - The sales orders, at most `dataserviceConfig.pageSize`
# + hasMore - Whether more sales orders exist
public type SalesOrderRelatedPartialList record {
    SalesOrderRelatedPartial[] items;
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
    datastore: dataservice:MYSQL,
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
                datastore: dataservice:MYSQL,
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
                datastore: dataservice:MYSQL,
                fields: dataserviceOrderItemFields
            }
        }
    ]
};

# The response to creating one sales order.
#
# + body - The created sales order
public type SalesOrderCreated record {|
    *http:Created;
    SalesOrderPayload body;
|};

# The response to creating several sales orders.
#
# + body - The created sales orders
public type SalesOrderListCreated record {|
    *http:Created;
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
#
# + items - The order items
# + hasMore - Whether records exist after this page
public type OrderItemList record {
    OrderItem[] items;
    boolean hasMore;
};

# The conditions that order items match, as the `filter` query parameter holds them.
#
# + id - The conditions on the `id` field
# + sku - The conditions on the `sku` field
# + quantity - The conditions on the `quantity` field
# + price - The conditions on the `price` field
# + salesorderId - The conditions on the `salesorderId` field
# + productId - The conditions on the `productId` field
public type OrderItemFilter record {|
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
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
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} quantity?;
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} price?;
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} salesorderId?;
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
#
# + id - The `id` field of `OrderItem`
# + sku - The `sku` field of `OrderItem`
# + quantity - The `quantity` field of `OrderItem`
# + price - The `price` field of `OrderItem`
# + salesorderId - The key of the related 'SalesOrder'.
# + productId - The key of the related 'Product'.
# + salesOrder - The related sales order, when `fields` names it
# + product - The related product, when `fields` names it
public type OrderItemPartial record {|
    int id;
    string sku?;
    int quantity?;
    decimal price?;
    int salesorderId?;
    int productId?;
    SalesOrderRelatedPartial? salesOrder?;
    ProductRelatedPartial? product?;
|};

# A list of order items with the fields named in the `fields` query parameter.
#
# + items - The order items
# + hasMore - Whether records exist after this page
public type OrderItemPartialList record {
    OrderItemPartial[] items;
    boolean hasMore;
};

# An order item read through a relation, with the fields named in the `fields` query parameter.
#
# + id - The `id` field of `OrderItem`
# + sku - The `sku` field of `OrderItem`
# + quantity - The `quantity` field of `OrderItem`
# + price - The `price` field of `OrderItem`
# + salesorderId - The key of the related 'SalesOrder'.
# + productId - The key of the related 'Product'.
public type OrderItemRelatedPartial record {|
    int id;
    string sku?;
    int quantity?;
    decimal price?;
    int salesorderId?;
    int productId?;
|};

# The order items read through a relation, with the fields named in the `fields` query parameter.
#
# + items - The order items, at most `dataserviceConfig.pageSize`
# + hasMore - Whether more order items exist
public type OrderItemRelatedPartialList record {
    OrderItemRelatedPartial[] items;
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
    datastore: dataservice:MYSQL,
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
                datastore: dataservice:MYSQL,
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
                datastore: dataservice:MYSQL,
                fields: dataserviceProductFields
            }
        }
    ]
};

# The response to creating one order item.
#
# + body - The created order item
public type OrderItemCreated record {|
    *http:Created;
    OrderItem body;
|};

# The response to creating several order items.
#
# + body - The created order items
public type OrderItemListCreated record {|
    *http:Created;
    OrderItemList body;
|};

# A list of products.
#
# + items - The products
# + hasMore - Whether records exist after this page
public type ProductList record {
    Product[] items;
    boolean hasMore;
};

# The conditions that products match, as the `filter` query parameter holds them.
#
# + id - The conditions on the `id` field
# + name - The conditions on the `name` field
# + description - The conditions on the `description` field
# + attr01 - The conditions on the `attr01` field
# + attr02 - The conditions on the `attr02` field
# + attr03 - The conditions on the `attr03` field
# + attr04 - The conditions on the `attr04` field
# + attr05 - The conditions on the `attr05` field
# + attr06 - The conditions on the `attr06` field
# + attr07 - The conditions on the `attr07` field
# + attr08 - The conditions on the `attr08` field
# + attr09 - The conditions on the `attr09` field
# + attr10 - The conditions on the `attr10` field
# + attr11 - The conditions on the `attr11` field
# + attr12 - The conditions on the `attr12` field
# + attr13 - The conditions on the `attr13` field
# + attr14 - The conditions on the `attr14` field
# + num01 - The conditions on the `num01` field
# + num02 - The conditions on the `num02` field
# + num03 - The conditions on the `num03` field
# + num04 - The conditions on the `num04` field
# + num05 - The conditions on the `num05` field
# + num06 - The conditions on the `num06` field
# + num07 - The conditions on the `num07` field
# + dec01 - The conditions on the `dec01` field
# + dec02 - The conditions on the `dec02` field
# + dec03 - The conditions on the `dec03` field
# + dec04 - The conditions on the `dec04` field
# + dec05 - The conditions on the `dec05` field
# + dec06 - The conditions on the `dec06` field
public type ProductFilter record {|
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} id?;
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
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num01?;
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num02?;
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num03?;
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num04?;
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num05?;
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num06?;
    record {|
        int eq?;
        int ne?;
        int lt?;
        int lte?;
        int gt?;
        int gte?;
        int[] anyOf?;
    |} num07?;
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec01?;
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec02?;
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec03?;
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec04?;
    record {|
        decimal eq?;
        decimal ne?;
        decimal lt?;
        decimal lte?;
        decimal gt?;
        decimal gte?;
        decimal[] anyOf?;
    |} dec05?;
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
#
# + id - The `id` field of `Product`
# + name - The `name` field of `Product`
# + description - The `description` field of `Product`
# + attr01 - The `attr01` field of `Product`
# + attr02 - The `attr02` field of `Product`
# + attr03 - The `attr03` field of `Product`
# + attr04 - The `attr04` field of `Product`
# + attr05 - The `attr05` field of `Product`
# + attr06 - The `attr06` field of `Product`
# + attr07 - The `attr07` field of `Product`
# + attr08 - The `attr08` field of `Product`
# + attr09 - The `attr09` field of `Product`
# + attr10 - The `attr10` field of `Product`
# + attr11 - The `attr11` field of `Product`
# + attr12 - The `attr12` field of `Product`
# + attr13 - The `attr13` field of `Product`
# + attr14 - The `attr14` field of `Product`
# + num01 - The `num01` field of `Product`
# + num02 - The `num02` field of `Product`
# + num03 - The `num03` field of `Product`
# + num04 - The `num04` field of `Product`
# + num05 - The `num05` field of `Product`
# + num06 - The `num06` field of `Product`
# + num07 - The `num07` field of `Product`
# + dec01 - The `dec01` field of `Product`
# + dec02 - The `dec02` field of `Product`
# + dec03 - The `dec03` field of `Product`
# + dec04 - The `dec04` field of `Product`
# + dec05 - The `dec05` field of `Product`
# + dec06 - The `dec06` field of `Product`
# + orderItems - The related order items, when `fields` names them
public type ProductPartial record {|
    int id;
    string name?;
    string description?;
    string attr01?;
    string attr02?;
    string attr03?;
    string attr04?;
    string attr05?;
    string attr06?;
    string attr07?;
    string attr08?;
    string attr09?;
    string attr10?;
    string attr11?;
    string attr12?;
    string attr13?;
    string attr14?;
    int num01?;
    int num02?;
    int num03?;
    int num04?;
    int num05?;
    int num06?;
    int num07?;
    decimal dec01?;
    decimal dec02?;
    decimal dec03?;
    decimal dec04?;
    decimal dec05?;
    decimal dec06?;
    OrderItemRelatedPartialList orderItems?;
|};

# A list of products with the fields named in the `fields` query parameter.
#
# + items - The products
# + hasMore - Whether records exist after this page
public type ProductPartialList record {
    ProductPartial[] items;
    boolean hasMore;
};

# A product read through a relation, with the fields named in the `fields` query parameter.
#
# + id - The `id` field of `Product`
# + name - The `name` field of `Product`
# + description - The `description` field of `Product`
# + attr01 - The `attr01` field of `Product`
# + attr02 - The `attr02` field of `Product`
# + attr03 - The `attr03` field of `Product`
# + attr04 - The `attr04` field of `Product`
# + attr05 - The `attr05` field of `Product`
# + attr06 - The `attr06` field of `Product`
# + attr07 - The `attr07` field of `Product`
# + attr08 - The `attr08` field of `Product`
# + attr09 - The `attr09` field of `Product`
# + attr10 - The `attr10` field of `Product`
# + attr11 - The `attr11` field of `Product`
# + attr12 - The `attr12` field of `Product`
# + attr13 - The `attr13` field of `Product`
# + attr14 - The `attr14` field of `Product`
# + num01 - The `num01` field of `Product`
# + num02 - The `num02` field of `Product`
# + num03 - The `num03` field of `Product`
# + num04 - The `num04` field of `Product`
# + num05 - The `num05` field of `Product`
# + num06 - The `num06` field of `Product`
# + num07 - The `num07` field of `Product`
# + dec01 - The `dec01` field of `Product`
# + dec02 - The `dec02` field of `Product`
# + dec03 - The `dec03` field of `Product`
# + dec04 - The `dec04` field of `Product`
# + dec05 - The `dec05` field of `Product`
# + dec06 - The `dec06` field of `Product`
public type ProductRelatedPartial record {|
    int id;
    string name?;
    string description?;
    string attr01?;
    string attr02?;
    string attr03?;
    string attr04?;
    string attr05?;
    string attr06?;
    string attr07?;
    string attr08?;
    string attr09?;
    string attr10?;
    string attr11?;
    string attr12?;
    string attr13?;
    string attr14?;
    int num01?;
    int num02?;
    int num03?;
    int num04?;
    int num05?;
    int num06?;
    int num07?;
    decimal dec01?;
    decimal dec02?;
    decimal dec03?;
    decimal dec04?;
    decimal dec05?;
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
    datastore: dataservice:MYSQL,
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
                datastore: dataservice:MYSQL,
                fields: dataserviceOrderItemFields
            }
        }
    ]
};

# The response to creating one product.
#
# + body - The created product
public type ProductCreated record {|
    *http:Created;
    Product body;
|};

# The response to creating several products.
#
# + body - The created products
public type ProductListCreated record {|
    *http:Created;
    ProductList body;
|};
