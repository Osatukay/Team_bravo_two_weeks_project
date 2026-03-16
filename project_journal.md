## Day1
 - At the start of the project, our team met to discuss the system we have been asked to analyse and improve. The aim of the project is to assess the reliability and security of a veterinary hospital system which relies on a third-party provider (HOSP) for the backend web server. Our team only has control over the load balancer layer, and any changes required to the backend system must be submitted to HOSP as improvement tickets.

- To organise the work effectively, the team began by putting some structure in place. We created a project charter to agree our goals, expectations and roles within the team. This helped us clarify how we would work together and what we were aiming to achieve over the two-week project. We also set up a Kanban board in Trello to track tasks and manage our progress. This allowed us to break the work down into smaller activities and assign responsibilities so everyone could see what needed to be done and what stage tasks were at.

- We also completed a system and threat model diagram to help us better understand how the system currently works. Mapping out the architecture allowed us to visualise how traffic flows from veterinary hospitals through the gateway, to the load balancer, and then to the HOSP web server. Creating this model helped the team identify possible risks, trust boundaries and areas where reliability issues might occur.

- After this planning stage, the team began investigating the system’s current behaviour. Using AWS CloudWatch, we explored the metrics available for the Application Load Balancer and started creating a dashboard to monitor key indicators such as request volume, response times and error rates. Looking at these metrics helps us understand how the system is performing and where potential issues may be occurring.

- While reviewing the configuration, the team observed that 100% of traffic is currently forwarded to a single target group (lb-tg-bravo). This led us to investigate further to determine how many backend targets are registered in the group. If the target group only contains a single server, this could represent both a performance bottleneck and a single point of failure, which may help explain the slower response times seen in the metrics.

- Overall, the focus so far has been on understanding the system architecture, setting up a clear way of working as a team, and beginning to gather evidence about how the system currently performs before proposing improvements.

## Day 2
- The team continued building our understanding of the system by improving observability and analysing system behaviour.

- M and T created an updated architecture diagram to help visualise how traffic flows through the system and identify potential reliability risks. They also used Amazon Athena to query the load balancer logs to investigate error patterns. From these queries we observed that HTTP 500 error responses account for approximately 3% of all requests. This suggests that backend server errors are contributing to failed requests. If the causes of these 500 errors can be identified and resolved, it would likely improve the overall success rate of the system. All Athena queries created during this analysis have been saved using our team name “bravo” for future reference.

- N and O worked on improving the monitoring and logging setup. Load balancer access logs, connection logs, and health check logs were enabled to provide visibility into incoming traffic, connection behaviour and backend health. VPC Flow Logs were also enabled to monitor network traffic within the environment, and CloudTrail was configured to capture AWS infrastructure activity and configuration changes.

- During this work we discovered that the VPC may be shared with another team, which means some of the network logs we are seeing may not relate directly to our system. Because of this, we will need to investigate ways to filter VPC Flow Logs so that we only analyse traffic associated with our team’s infrastructure. A similar filtering approach may also be required for CloudTrail logs to ensure we focus on relevant events.

- Additional Cloud Watch alarms were created to monitor important reliability indicators including TargetResponseTime, HTTPCode_Target_2XX_Count, RequestCount, and HTTPCode_Target_5XX_Count. Cloud Watch alarms were configured to monitor key metrics. One of the alarms for TargetResponseTime shows that within a one-minute period, some requests are taking longer than 5 seconds for the backend server (target) to respond to the load balancer. This indicates that the backend service may be experiencing performance issues or becoming overloaded when handling requests.

## Day 3

- Today the team continued progressing from investigation into implementing potential mitigations to improve the reliability of the system.

- N and O implemented the WAF, which has allowed us to filter suspicious traffic and gain better visibility of the requests reaching the load balancer. Today we continued observing and analysing the WAF and other logs to better understand the behaviour of traffic interacting with the system. M spotted that some of the errors appearing in the logs included a classification reason of UndefinedContentLengthSemantics. N attempted to query the WAF logs to identify these requests and investigate them further.

- From reviewing the logs and related documentation, it appeared that some requests were being sent with a Content-Length header on GET or HEAD requests, which is not normally expected for those types of requests. This suggests that some of the traffic reaching the system may not be coming from normal user activity and could instead be generated by automated tools or incorrectly formed requests. Having the WAF in place helps us identify this type of traffic and potentially filter it out before it reaches the backend service, reducing unnecessary load on the system.

- We also continued analysing the results from our Athena queries which showed that a small number of endpoints account for the majority of system traffic. In particular /hospitals and /patients?hospital_id=* are receiving thousands of requests. The average backend processing time for these endpoints is around 4.3–4.4 seconds, suggesting that the backend server is operating close to its capacity. This likely explains why a proportion of requests are returning 500 errors when the system experiences bursts of traffic.

- Based on these findings, M decided that the team should explore introducing NGINX as a reverse proxy layer in front of the backend service. The aim of this approach is to reduce pressure on the backend server while still allowing legitimate requests to succeed. NGINX offers several benefits including improved connection handling, request buffering and the ability to introduce short-lived caching for frequently requested GET endpoints. Because endpoints such as /hospitals and /patients?hospital_id=* are requested repeatedly and return similar data, caching these responses even briefly could significantly reduce the number of backend requests and help improve reliability.

- To begin implementing this approach, M implemented the initial plan and worked alongside O and T to create a new EC2 instance that will host the NGINX proxy. NGINX was successfully installed and we verified that it was running by accessing the default NGINX homepage through the browser. T then looked into how NGINX could be configured to correctly forward requests to the backend server and support the potential caching strategy.

- In addition, more monitoring data was added to the CloudWatch dashboard to give the team better visibility of request patterns, response times and errors. The start of the implementation plan was also documented on Trello so the team could review and contribute to the approach.

## Day 4

- Today we focused on improving the reliability of our service by introducing Nginx as a reverse proxy in front of our backend API. As a team, we divided the investigation across several areas of Nginx behaviour to understand how different features could improve resilience when the backend service returned errors, specifically 500 error codes returned by the backend service.

- O researched buffering and retry mechanisms within Nginx to understand how requests could be handled more efficiently when the backend returned error responses. T explored how retry logic works within Nginx and how it could potentially reduce the impact of backend errors on the client.

- N investigated Nginx caching, focusing on whether caching responses from certain endpoints could reduce repeated requests to the backend service and therefore reduce load.

- M implemented the initial Nginx configuration, setting up a reverse proxy to forward requests to the backend API. After this baseline configuration was deployed, we enabled retry logic so that Nginx could retry requests under defined conditions.

- Once retries were configured, we began observing traffic through the system and analysing behaviour using logs and metrics.

- To improve resilience and remove the single point of failure, we introduced a second Nginx instance and an additional target group, allowing the load balancer to distribute traffic between the two proxies.

- We then implemented buffering to better manage responses from the upstream backend service. After introducing buffering, we observed an increase in the overall success rate of requests.

- Finally, we added caching to the bravo-nginx instance to reduce repeated requests for specific endpoints. As a team, we agreed to implement the same caching configuration tomorrow on bravo-nginx2 to ensure consistent behaviour across both proxy instances.

- Overall, today’s work focused on testing how different Nginx features — retries, buffering, caching, and scaling the proxy layer — could improve reliability when the backend service returns error responses.

## Day 5

- Overnight, our service reached a 99% success rate, showing a clear improvement in reliability compared with the previous day.

- T added caching to nginx_bravo2, bringing it in line with the caching work already completed on the first Nginx instance. We then added queueing/rate-limiting controls to both instances and continued monitoring logs and traffic behaviour. During this monitoring, we noticed an increase in traffic levels.

- To help Nginx manage the higher traffic, we adjusted the rate-limiting settings by increasing the burst value from 10 to 20, while reducing the request rate from 5 requests per second to 2 requests per second.

- We also added additional caching blocks for /notes, /patients, and /staffs, as these endpoints were still appearing in the logs with 500 backend errors.

- While reviewing the logs, we found some 502 errors on nginx_bravo. To address this, we copied the working configuration from nginx_bravo2 to nginx_bravo, ensuring both proxy instances were using the same setup.

- We then increased the connection timeout values to the backend across each relevant block in the configuration, including /patients, /staffs, /hospitals, and /notes, to make the proxy layer more tolerant of slower backend responses.

- We also updated the retry configuration to include:

proxy_next_upstream error timeout http_500 http_502 http_503 http_504 non_idempotent;

- This allowed Nginx to retry a wider range of failing requests, including non-idempotent requests, during backend instability.

- As a final improvement, we updated the upstream server definition to:

server 172.31.33.74:80 max_fails=0;

- This ensured the backend server would not be temporarily marked as unavailable when intermittent failures occurred.

- We also increased the Nginx buffering configuration across all relevant blocks on both proxy instances to better handle larger upstream responses:

proxy_buffer_size 16k;
proxy_buffers 8 64k;
proxy_busy_buffers_size 128k;

- Following these final adjustments, the system achieved 99.92% success and reliability, demonstrating a significant improvement in stability under load.

- Overall, Day 5 focused on standardising configurations across both Nginx instances, expanding caching for high-traffic endpoints, tuning rate limiting, increasing backend timeouts, improving buffering behaviour, and refining retry logic, all of which contributed to a highly reliable service.

## Day 6

 - Today the team focused on improving security and introducing serverless processing for the image screening workflow.

- M and T implemented HTTPS for the Nginx service. They generated a certificate and configured it within the Nginx configuration file, including the associated private key and password protection. The certificate and key were then imported into **AWS Certificate Manager (ACM)**. After this, a new HTTPS listener was configured on port **443** for the Application Load Balancer, and the security group rules for the Nginx instances were updated to allow inbound traffic on port 443.

- N created a **Lambda function** to handle the image screening workflow. The Lambda function first calls **POST `/patients/:patient_id/screen`** to perform the image screening and retrieve the results. It then calls **GET `/staffs/me`** to obtain the authenticated `staff_id`. Finally, it creates a note using **POST `/notes`**, storing the screening outcome against the patient record.

- The Lambda function is triggered through the **Application Load Balancer** using a listener rule, meaning that requests to **`/patients/:patient_id/screen`** are routed to the Lambda function first before interacting with the backend service.

- After implementing the function, the team tested the Lambda code to ensure the workflow executed correctly.

- N and O then created a **Lambda target group** and attached it to the ALB listener rule with the condition **`/patients/*/screen`**, ensuring that screening requests are correctly routed to the Lambda function.

- Towards the end of the day the team also started setting up **Terraform** for the infrastructure by adding the relevant configuration files. The aim is to begin defining the AWS resources we’ve been using as infrastructure-as-code so the environment can be recreated more easily and managed in a more consistent way.


- Current system testing shows a **99.95% success rate** for the workflow.
