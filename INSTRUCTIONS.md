The requirements for the test project are:

The smart contract should include the following functionality:
- [x] Allow users to add new food entries. Each food entry should be a struct containing the following information.
  - [x] Date/time when the food was taken (timestamp).
  - [x] Food/product name (string).
  - [x] Calorie value (uint).

- [x] Store the daily calorie threshold limit as a constant (2,100 by default)
- [x] and provide a function for the admin to update this limit per user. This function should be restricted to admin access only.

- [x] Implement an event for adding food entries. This event should be emitted when a user adds a new food entry.

- [x] Create a modifier that ensures only the admin can access certain functions (updating the daily calorie threshold limit and managing existing food entries).

- [x] Implement user authentication/authorization using Ethereum addresses. You can use the msg.sender property to identify the user interacting with the smart contract.

- [ ] For the admin reporting requirements, create functions that return the following information:

  - [ ] Number of added entries in the last 7 days vs. added entries the week before that (including the current day).

  - [ ] The average number of calories added per user for the last 7 days.

  - [ ] Use Web3.js or a similar library to interact with the Ethereum blockchain and your smart contract.

This is a Backend project, no UI is required, but it should be access from a REST API or CLI.

Please use this private repository to version-control your code:
https://git.toptal.com/eluttner/rockymurdoch.tech

Helpful take-home project guidelines:

• This project will be used to evaluate your skills and should be fully functional without any obvious missing pieces. We will evaluate the project as if you were delivering it to a customer.
• The deadline to submit your completed project is 7 days from the date you received the project requirements.
• If you schedule your final interview after the 7-day deadline, make sure to submit your completed project and all code to the private repository before the deadline. Everything that is submitted after the deadline will not be taken into consideration.
• If you schedule your final interview before the 7-day deadline, make sure to submit your completed project and all code to the private repository before the scheduled call.
• Please note that your application may be declined if you reschedule your interview less than 12 hours in advance, you’ve rescheduled more than once, or you fail to attend your interview without prior warning.

Please schedule an interview time that is most suitable for you. Bear in mind that you will need to present a finished project during this interview.

Once you pick an appointment time, we’ll email you with additional meeting details and the contact details of another senior developer from our team who will assess your project and conduct your next interview. They are acting as your client for this project and are your point of contact for any questions you may have during the development of this project.