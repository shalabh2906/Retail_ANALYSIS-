%web_drop_table(WORK.RETAIL);


FILENAME REFFILE '/folders/myfolders/Project 04_Retail Analysis_Dataset.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.RETAIL;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.RETAIL; 
RUN;


%web_open_table(WORK.RETAIL);

PROC contents DATA=RETAIL;
RUN;

/* A NEW VARIABLE NAMED TOTAL_SALES HAS TO BE CREATED. 
AS THE GIVEN DATASET HAS NO PROVISION TO MEASURE THE TOTAL SALE OF EACH PRODUCT. 
       Total_Sales = Sales*Quantity is being created*/
      
proc sql;
create table RETAIL_CHANGED as
	select *, Sales*Quantity as Total_Sales from RETAIL;
	quit;
	

/* TO GET DESCRIPTIVE STATISTICS */
Proc Means data=RETAIL_CHANGED;
run;


/* CHECHKING SIGNIFICANCE OF INDIVIDUAL VARIABLE WITH TOTAL_SALES*/
proc reg data=RETAIL_CHANGED;
	model Total_Sales = Quantity; /*Checking the suitability of variable quatity*/
	var Total_Sales;
	Run;

/*It can be seen that hypothesis testing shows positive correlation with 42% predictability. 
Implies Quantity is a significant variable.*/

/*Checking the suitability of variable PROFIT.*/
proc reg data=RETAIL_CHANGED;
	model Total_Sales = Profit; /*Checking the suitability of variable Profit*/
	var Total_Sales;
	Run;
/* hypothesis testing shows positive correlation with 30% predictability.
 Pr value (<0.05) satisfied to negate the null hypothesis. 
Implies Profit is a significant variable with linear relation with Total_Sales.
Also notice Coefficient of Variance which is higher at 45%*/

/*Checking the suitability of variable DISCOUNT.*/
proc reg data=RETAIL_CHANGED;
	model Total_Sales = Discount; 
	var Total_Sales;
	Run;
/*The t-test data shows that there is no significant correlation with this variable to 
the value of Dependant variable. 
The p-value of 0.84 is way above 0.05.
R-Square data shows no predictability too with a poor value of .0014%. 
Hence Discount is not a suitable variable for regression analysis.*/	

/*CHECKING Multivariate Regression Analysis*/
proc reg data=RETAIL_CHANGED;
	model Total_Sales = Quantity Profit Shipping_Cost;
	var Total_Sales;
	Run;
/*The assumption for performing regression analysis SHOWS THAT VARIABLES are not independent of each other. 
Shipping cost and Profit have a direct discernible relation here hence any one would suffice in predicting the variability with Total_Sales. 
Rest variables have good positive correlation with R^2 value boosted to over 88%*/

/* Performing Regression WITHOUT Shipping_Cost*/
proc reg data=RETAIL_CHANGED;
	model Total_Sales = Quantity Profit;
	var Total_Sales;
	Run;

/*1.  The R^2 88% IS VERY GOOD.
2. MEANS approximately 88% of the variation of Total_Sales is explained by the independent variables.
3. Based on t-test , the Pr-values for Quantity and Profit < 0.05 
indicating sufficient evidence for predicting the Total_Sales. 
4. This shows that increase in 1 quantity of product would raise the total sales by around $166 
and increase in profit by $1 would have meant sales would go up by $4.1.*/


/*The histogram and quantile plots show a healthy model.  
Performing BoxCox test to validate our model*/

ODS GRAPHICS ON;
 PROC TRANSREG DATA = RETAIL_CHANGED TEST;
 MODEL BOXCOX(Total_Sales) = IDENTITY(Quantity Profit: );
 RUN;
ODS GRAPHICS OFF;
