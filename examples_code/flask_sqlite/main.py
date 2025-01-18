from flask import Flask
from flask import render_template,request
import sqlite3

app = Flask(__name__)
tables=[
"customers" ,    "offices"  ,     "orders" ,       "productlines",
"employees"  ,   "orderdetails"  ,"payments",      "products"
]
offices_columns=[
  "officeCode",
  "city",
  "phone",
  "addressLine1",
  "addressLine2",
  "state",
  "country",
  "postalCode" ,
  "territory"
]

@app.route("/orderdetails")
def orderdetails():
    orderNumber = request.args.get('orderNumber', '')
    sort = request.args.get('sort', '')

    con = sqlite3.connect("custom")


    cur=con.cursor()


    sql=f"""
    select orders.orderNumber,orders.orderDate,
    orderdetails.productCode, orderdetails.quantityOrdered,
    orderdetails.priceEach,
    orders.status,orders.shippedDate,
    customers.customerName

    from orders,orderdetails,customers
    where orders.orderNumber=orderdetails.orderNumber
    and orders.orderNumber={orderNumber}
    and orders.customerNumber=customers.customerNumber
    """
    try:
        res = cur.execute(sql)
        names = list(map(lambda x: x[0], cur.description))
    except  :
            print(sql)
    if len(sort)>0:
        sql=sql+f" order by {sort}"
    print(sql)
    try:
        res = cur.execute(sql)
        rez=res.fetchall()
    except  :
        print(sql)
        return "error"


    #print (cur.description)
    tablename="orders"

    return render_template('orderdetail.html',rez=rez,orderNumber=orderNumber,tablename=tablename,col=names,tables=tables)



@app.route("/table/<tablename>")
def table(tablename):
    sort = request.args.get('sort', '')
    filter =request.args.get('filter', '')
    con = sqlite3.connect("custom")


    cur=con.cursor()
    if tablename=="orderdetails" :
        pass
    if tablename=="ordercustomers" :
        col=["orderNumber", 	"orderDate",
             	"requiredDate" ,	"shippedDate" ,	"status", 	"comments",
                 "customers.customerName",   "customers.contactLastName" ,  "customers.contactFirstName"  ]
        sql=f"""
        SELECT {', '.join(col)} from orders,customers
        where orders.customerNumber = customers.customerNumber
        """
        if len(sort)>0:
                    sql=sql+f" order by {sort}"
        res = cur.execute(sql)
        names = list(map(lambda x: x[0], cur.description))
        res = cur.execute(sql)
        rez=res.fetchall()
    else:
        sql=f'SELECT * from {tablename}'
        res = cur.execute(sql)
        names = list(map(lambda x: x[0], cur.description))
        if len(sort)>0:
            sql=sql+f" order by {sort}"
        res = cur.execute(sql)
        rez=res.fetchall()

    #print (cur.description)


    return render_template('tables.html',rez=rez,tablename=tablename,col=names,tables=tables)



@app.route('/')
def hello():
    return render_template('home.html',tables=tables)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000,debug=True)
