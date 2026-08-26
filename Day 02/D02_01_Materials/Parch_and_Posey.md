# Parch & Posey Database 

**Parch and Posey** is a fictional company that specializes in selling paper products. 
- They have 50 sales representatives spread across the United States, organized into four regions.
- Parch and Posey offers three types of paper: standard, poster, and glossy.
- Their primary clients are large Fortune 100 companies, attracted through advertising on Google, Facebook, and Twitter.

![Parch and Posey ERD](parch_and_posey_erd.svg)


**Note:** 

Parch and Posey is not a real company; it's originaly fabricated for educational purposes by the Udacity SQL for Data Analysis course creator to simulate real-world business problems. We modified it for this course to be compatible with MySQL.



## Relationships

- One **region** has many **sales_reps** (1:N)
- One **sales_rep** manages many **accounts** (1:N)
- One **account** places many **orders** (1:N)
- One **account** generates many **web_events** (1:N)


```mermaid
erDiagram
    REGION ||--o{ SALES_REPS : "has"
    SALES_REPS ||--o{ ACCOUNTS : "manages"
    ACCOUNTS ||--o{ ORDERS : "places"
    ACCOUNTS ||--o{ WEB_EVENTS : "generates"

    REGION {
        int id PK
        varchar name
    }

    SALES_REPS {
        int id PK
        varchar name
        int region_id FK
    }

    ACCOUNTS {
        int id PK
        varchar name
        varchar website
        numeric latitude
        numeric longitude
        varchar primary_poc
        int sales_rep_id FK
    }

    ORDERS {
        int id PK
        int account_id FK
        timestamp occurred_at
        int standard_qty
        int gloss_qty
        int poster_qty
        int total
        numeric standard_amt_usd
        numeric gloss_amt_usd
        numeric poster_amt_usd
        numeric total_amt_usd
    }

    WEB_EVENTS {
        int id PK
        int account_id FK
        timestamp occurred_at
        varchar channel
    }
```