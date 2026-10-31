import pandas as pd
import pandas_gbq
import os
import logging
from sqlalchemy import create_engine
from urllib.parse import quote_plus
from dotenv import load_dotenv

load_dotenv()
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# same db_* variables from os.getenv as in your pipeline
db_password = os.getenv("DB_PASSWORD")
db_user = os.getenv("DB_USER")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")
project_id = os.getenv("GCP_PROJECT_ID")

def read_from_postgres(engine):
    # read the whole sales table into a DataFrame
    try :
        df = pd.read_sql("SELECT * FROM sales", con=engine)
        logging.info(f"Read {len(df)} rows from Postgres")
        return df
    except Exception as e:
        logging.error(f"Error reading from Postgres: {e}")
        raise

def load_to_bigquery(df,destination_table):
    try:
        pandas_gbq.to_gbq(
            df,
            destination_table=destination_table,
            project_id=project_id,
            if_exists="replace",   
        )
        logging.info(f"Loaded {len(df)} rows into BigQuery table '{destination_table}'")
    except Exception as e:
        logging.error(f"Error loading to BigQuery: {e}")
        raise
if __name__ == "__main__":
   try:
        encoded_pass = quote_plus(db_password)
        engine = create_engine(
            f'postgresql+psycopg://{db_user}:{encoded_pass}@{db_host}:{db_port}/{db_name}'
        )
 
        df = read_from_postgres(engine)
        load_to_bigquery(df, "sales_dw.sales_py")
 
        logging.info("Pipeline completed successfully!")
   except Exception as e:
        logging.error(f"Pipeline failed: {e}")
        raise