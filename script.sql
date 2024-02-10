-- 1a)

-- SELECT pr.npi, SUM(pscn.total_claim_count) as totalClaims
-- FROM prescriber as pr
-- INNER JOIN prescription as pscn ON pr.npi = pscn.npi
-- GROUP BY pr.npi
-- ORDER BY totalClaims DESC
-- LIMIT 1;


-- 1b) Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

-- SELECT pr.npi, pr.nppes_provider_first_name as FirstName, pr.nppes_provider_last_org_name as LastName, pr.specialty_description as Specialty, SUM(pscn.total_claim_count) as totalClaims
-- FROM prescriber as pr
-- INNER JOIN prescription as pscn ON pr.npi = pscn.npi
-- GROUP BY pr.npi, FirstName, LastName, Specialty
-- ORDER BY totalClaims DESC
-- LIMIT 1;

-- 2a) Which specialty had the most total number of claims (totaled over all drugs)?

-- SELECT pr.specialty_description as Specialty, SUM(pscn.total_claim_count) as totalClaims
-- FROM prescriber as pr
-- INNER JOIN prescription as pscn ON pr.npi = pscn.npi
-- GROUP BY Specialty
-- ORDER BY totalClaims DESC
-- LIMIT 5;

--2b) Which specialty had the most total number of claims for opioids?

-- SELECT pr.specialty_description as Specialty, SUM(pscn.total_claim_count) as totalClaims
-- FROM prescriber as pr
-- INNER JOIN prescription as pscn ON pr.npi = pscn.npi
-- INNER JOIN drug on pscn.drug_name = drug.drug_name
-- WHERE drug.opioid_drug_flag = 'Y'
-- GROUP BY Specialty
-- ORDER BY totalClaims DESC
-- LIMIT 5;

--2c) Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

-- SELECT pr.specialty_description as Specialty, SUM(pscn.total_claim_count) as totalClaims
-- FROM prescriber as pr
-- LEFT JOIN prescription as pscn ON pr.npi = pscn.npi
-- GROUP BY Specialty
-- HAVING totalClaims IS NULL OR totalClaims = 0;

-- WITH spec_table AS (
-- SELECT pr.specialty_description as Specialty, SUM(pscn.total_claim_count) as totalClaims
-- FROM prescriber as pr
-- LEFT JOIN prescription as pscn ON pr.npi = pscn.npi
-- GROUP BY Specialty)
-- Select * from spec_table
-- WHERE totalClaims IS NULL


-- SELECT pr.specialty_description as Specialty,
--        SUM(CASE WHEN pscn.total_claim_count IS NULL THEN 0 ELSE pscn.total_claim_count END) as totalClaims
-- FROM prescriber as pr
-- LEFT JOIN prescription as pscn ON pr.npi = pscn.npi
-- GROUP BY Specialty
-- HAVING totalClaims = 0

-- 3a) Which drug (generic_name) had the highest total drug cost?
-- SELECT drug.generic_name, prescription.total_drug_cost as total_cost
-- FROM drug
-- INNER JOIN prescription ON drug.drug_name=prescription.drug_name
-- ORDER BY total_cost DESC
-- LIMIT 5

--3b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

-- SELECT drug.generic_name, prescription.total_drug_cost as total_cost, prescription.total_day_supply as days,
--        ROUND(prescription.total_drug_cost / prescription.total_day_supply, 2) as cost_per_day
-- FROM drug
-- INNER JOIN prescription ON drug.drug_name = prescription.drug_name
-- ORDER BY cost_per_day DESC
-- LIMIT 5;

-- 4a) For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

-- SELECT drug.generic_name, 
-- CASE
--     WHEN drug.opioid_drug_flag = 'Y' OR drug.long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
--     WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
--     ELSE 'neither'
-- END as drug_type
-- from drug


--4b) Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- WITH drug_table AS (
-- SELECT drug.generic_name, 
-- CASE
--     WHEN drug.opioid_drug_flag = 'Y' OR drug.long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
--     WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
--     ELSE 'neither'
-- END as drug_type, pscn.total_drug_cost
-- from drug
-- INNER JOIN prescription as pscn ON drug.drug_name = pscn.drug_name
-- 	)
-- SELECT drug_type, CAST(SUM(total_drug_cost) AS money) as totalcost
-- from drug_table
-- GROUP BY drug_type
-- ORDER BY totalcost

-- 5a) How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
-- SELECT COUNT(*)
-- FROM cbsa
-- INNER JOIN fips_county AS fc ON cbsa.fipscounty = fc.fipscounty
-- WHERE fc.state = 'TN'

-- 5b) Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- SELECT cbsa.cbsaname, pop.population as population
-- FROM cbsa
-- INNER JOIN population AS pop ON cbsa.fipscounty = pop.fipscounty
-- ORDER BY population DESC

-- 5c) What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- WITH poptable AS (
--     SELECT fc.county, pop.population, pop.fipscounty
--     FROM fips_county AS fc
--     INNER JOIN population as pop ON fc.fipscounty = pop.fipscounty
-- ),
-- cbsatable AS (
--     SELECT poptable.county, poptable.population, poptable.fipscounty, cbsa.cbsa
--     FROM poptable
--     LEFT JOIN cbsa ON cbsa.fipscounty = poptable.fipscounty
-- )
-- SELECT * FROM cbsatable
-- WHERE cbsa IS NULL
-- ORDER BY population DESC

-- 6a) Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

-- SELECT drug_name, total_claim_count FROM prescription
-- WHERE total_claim_count > 3000

--6b) For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

-- SELECT pscn.drug_name, drug.opioid_drug_flag, pscn.total_claim_count 
-- FROM prescription AS pscn
-- INNER JOIN drug on drug.drug_name = pscn.drug_name
-- WHERE pscn.total_claim_count > 3000

--6c) Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- SELECT pscn.drug_name, drug.opioid_drug_flag as is_opioid, pscn.total_claim_count, pr.nppes_provider_last_org_name AS LastName, pr.nppes_provider_first_name AS FirstName
-- FROM prescription AS pscn
-- INNER JOIN drug on drug.drug_name = pscn.drug_name
-- INNER JOIN prescriber AS pr on pscn.npi = pr.npi
-- WHERE pscn.total_claim_count > 3000 AND drug.opioid_drug_flag  = 'Y'

--Q7 The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- SELECT pr.npi, pscn.drug_name
-- FROM prescriber as pr
-- LEFT JOIN prescription as pscn ON pr.npi = pscn.npi
-- LEFT JOIN drug ON drug.drug_name = pscn.drug_name
-- WHERE pr.specialty_description = 'Pain Management' AND pr.nppes_provider_city = 'NASHVILLE' AND drug.opioid_drug_flag = 'Y'

SELECT npi,
	drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';








