# Organization Access Control & Age-Based Participation System

A comprehensive Rails application that implements organization-based access control and age-based participation rules for managing user access and participation within organizations.

## Features

### Organization-Based Access Control

- **Organization Membership**: Users can belong to organizations with different participation types (public, private, restricted)
- **Role-Based Permissions**: Hierarchical role system (admin, moderator, participant, viewer) with specific permissions
- **Organization Analytics**: Comprehensive reporting and analytics for organization metrics
- **Member Management**: Tools for managing organization members and their roles

### Age-Based Participation Rules

- **Age Verification**: Automatic age calculation and verification during registration
- **Age Group Classification**: Users are classified into age groups (child, teen, young_adult, adult, senior)
- **Age-Specific Rules**: Configurable participation rules for each age group
- **Content Filtering**: Different filtering levels (minimal, moderate, strict) based on age
- **Participation Restrictions**: Age-appropriate restrictions and limitations

### Parental Consent System

- **Consent Workflow**: Complete parental consent workflow for minors
- **Consent Management**: Request, approve, revoke, and renew parental consents
- **Expiry Tracking**: Automatic tracking of consent expiry dates
- **Notification System**: Notifications for pending and expired consents

## Technology Stack

- **Ruby on Rails 6.0.4**
- **PostgreSQL** - Database
- **Devise** - Authentication
- **Pundit** - Authorization
- **Bootstrap** - UI framework

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd org_access_control_app
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the server:
```bash
rails server
```

5. Visit `http://localhost:3000` in your browser

## Database Schema

### Core Models

- **User**: Users with age verification and organization membership
- **Organization**: Organizations with participation types and settings
- **Role**: Role definitions with permissions
- **UserRole**: Many-to-many relationship between users and roles
- **ParticipationRule**: Age-based participation rules for organizations
- **ParentalConsent**: Parental consent records for minors
- **OrganizationAnalytics**: Analytics and reporting data

### Key Relationships

- Users belong to Organizations
- Users have many Roles through UserRoles
- Organizations have many ParticipationRules
- Organizations have many OrganizationAnalytics
- Users can have ParentalConsents (as parent or child)

## Usage

### Organization Management

1. **Create Organization**: Users can create new organizations
2. **Join Organization**: Users can join existing organizations (based on participation type)
3. **Manage Members**: Organization admins can manage member roles and permissions
4. **Configure Rules**: Set up age-based participation rules

### Age-Based Participation

1. **Age Verification**: System automatically calculates and verifies user age
2. **Rule Configuration**: Admins configure participation rules for each age group
3. **Content Filtering**: Automatic content filtering based on age group
4. **Restriction Enforcement**: System enforces age-appropriate restrictions

### Parental Consent

1. **Request Consent**: Minors can request parental consent
2. **Approve Consent**: Parents can approve or deny consent requests
3. **Track Expiry**: System tracks consent expiry and sends notifications
4. **Renew Consent**: Expired consents can be renewed

### Analytics and Reporting

1. **Daily Reports**: Generate daily organization analytics
2. **Weekly Reports**: Weekly participation and growth metrics
3. **Monthly Reports**: Monthly comprehensive reports
4. **Age Group Analysis**: Detailed breakdown by age groups

## Sample Data

The application includes sample data with:

- **3 Organizations**: TechCorp Inc. (private), Youth Academy (restricted), Community Center (public)
- **10 Users**: Mix of adults, teens, and children across different organizations
- **Role Assignments**: Various role configurations demonstrating the hierarchy
- **Parental Consents**: Examples of approved, pending, and missing consents
- **Analytics Data**: Sample analytics for all organizations

### Sample Login Credentials

- **Admin**: admin@techcorp.com / password123
- **Teacher**: teacher@youthacademy.org / password123
- **Parent**: parent1@example.com / password123
- **Teen**: teen1@youthacademy.org / password123
- **Child**: child1@youthacademy.org / password123

## API Endpoints

The application includes RESTful API endpoints for:

- Organization management
- User management
- Participation rules
- Parental consents
- Analytics data

## Security Features

- **Authentication**: Devise-based user authentication
- **Authorization**: Pundit-based policy enforcement
- **Role-Based Access**: Hierarchical role system with specific permissions
- **Age Verification**: Secure age verification and validation
- **Parental Consent**: Secure consent workflow with audit trails

## Demo Scenarios

### Scenario 1: Organization Membership Verification
1. Login as admin@techcorp.com
2. Navigate to organization management
3. View member list and role assignments
4. Demonstrate role-based access control

### Scenario 2: Age-Based Participation Rules
1. Login as teacher@youthacademy.org
2. Navigate to participation rules
3. Configure different rules for child, teen, and adult age groups
4. Show how rules affect user participation

### Scenario 3: Parental Consent Workflow
1. Login as teen2@communitycenter.org (pending consent)
2. Show consent request process
3. Login as parent2@example.com
4. Demonstrate consent approval process

### Scenario 4: Organization Analytics
1. Login as admin@techcorp.com
2. Navigate to analytics dashboard
3. View member statistics, age group breakdowns
4. Show participation rates and growth metrics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please contact the development team.
