# Baker Street Scenarios - Cyber Range Investigation Scenarios

## 🕵️ Overview

*"The game is afoot, and every scenario tells a story of intrigue and investigation."*

Baker Street Scenarios represents the comprehensive collection of investigation scenarios for the Baker Street Labs cyber range. This section contains detailed scenarios inspired by Arthur Conan Doyle's Sherlock Holmes stories, each incorporating specific MITRE ATT&CK techniques and designed to test Palo Alto Networks security products.

## 🏗️ Architecture

The Baker Street Scenarios section is organized into specialized categories, each containing scenarios for specific testing objectives:

```
baker-street-scenarios/
├── investigations/     # Detailed investigation scenarios
├── templates/         # Scenario templates and frameworks
├── playbooks/         # Investigation playbooks and procedures
└── README.md         # This file
```

## 🎯 Investigation Scenarios

### 1. The Hound of the Baskervilles
**Difficulty**: Advanced  
**Duration**: 4-6 hours  
**MITRE Tactics**: Lateral Movement, Data Exfiltration, Persistence, Privilege Escalation

**Scenario**: A sophisticated APT group known as "The Hound" has infiltrated the Baskerville Corporation's network. The attackers have established persistence across multiple systems and are systematically exfiltrating sensitive data while maintaining stealth through living-off-the-land techniques.

**Key Techniques**:
- T1078: Valid Accounts
- T1053: Scheduled Task/Job
- T1055: Process Injection
- T1070: Indicator Removal on Host
- T1021: Remote Services
- T1041: Exfiltration Over C2 Channel

### 2. The Sign of Four
**Difficulty**: Intermediate  
**Duration**: 3-4 hours  
**MITRE Tactics**: Watering Hole, Social Engineering, Supply Chain, Initial Access

**Scenario**: A sophisticated threat actor has compromised a trusted software vendor and is distributing malicious updates to multiple organizations. The attackers are using a watering hole attack combined with social engineering to gain initial access and establish persistence.

**Key Techniques**:
- T1189: Drive-by Compromise
- T1195: Supply Chain Compromise
- T1566: Phishing
- T1059: Command and Scripting Interpreter
- T1053: Scheduled Task/Job

### 3. A Study in Scarlet
**Difficulty**: Beginner  
**Duration**: 2-3 hours  
**MITRE Tactics**: Initial Access, Privilege Escalation, Defense Evasion, Discovery

**Scenario**: A novice threat actor has gained initial access to a corporate network through a simple vulnerability and is attempting to escalate privileges and establish persistence. The attacker is using basic techniques but is learning and adapting as they progress through the network.

**Key Techniques**:
- T1190: Exploit Public-Facing Application
- T1059: Command and Scripting Interpreter
- T1053: Scheduled Task/Job
- T1068: Exploitation for Privilege Escalation
- T1070: Indicator Removal on Host

### 4. The Adventure of the Final Problem
**Difficulty**: Expert  
**Duration**: 6-8 hours  
**MITRE Tactics**: Advanced Persistent Threat, Zero-Day Exploits, Nation-State, Sophisticated Malware

**Scenario**: A sophisticated nation-state threat actor has deployed advanced persistent threat (APT) capabilities using zero-day exploits and custom malware. The attackers have established long-term persistence and are conducting espionage activities while evading detection through advanced techniques.

**Key Techniques**:
- T1195: Supply Chain Compromise
- T1059: Command and Scripting Interpreter
- T1053: Scheduled Task/Job
- T1055: Process Injection
- T1070: Indicator Removal on Host
- T1041: Exfiltration Over C2 Channel

### 5. The Adventure of the Copper Beeches
**Difficulty**: Intermediate  
**Duration**: 3-4 hours  
**MITRE Tactics**: Ransomware, Data Destruction, Financial Motivation, Impact

**Scenario**: A financially motivated threat actor has deployed ransomware across a corporate network, encrypting critical data and demanding payment. The attackers are using sophisticated techniques to maximize impact and pressure the organization into paying the ransom.

**Key Techniques**:
- T1190: Exploit Public-Facing Application
- T1059: Command and Scripting Interpreter
- T1053: Scheduled Task/Job
- T1486: Data Encrypted for Impact
- T1489: Service Stop
- T1490: Inhibit System Recovery

## 🚀 Deployment Strategy

### OpenShift Integration

All scenarios are designed to be deployed on Red Hat OpenShift:

- **Containerized Scenarios**: Each scenario as a set of containers
- **Network Isolation**: Isolated networks for different scenarios
- **Resource Management**: Controlled resource allocation for scenarios
- **Automated Deployment**: Infrastructure as Code for scenario deployment

### Scenario Lifecycle Management

- **Scenario Provisioning**: Automated scenario creation and configuration
- **Scenario Maintenance**: Regular updates and patching
- **Scenario Monitoring**: Health checks and performance monitoring
- **Scenario Cleanup**: Automated cleanup and reset procedures

## 🔧 Configuration

### Scenario Customization

- **Difficulty Levels**: Configurable difficulty for different skill levels
- **Duration Adjustments**: Flexible duration based on available time
- **Participant Scaling**: Scalable participant numbers
- **Tool Integration**: Integration with PAN security products

### PAN Product Integration

Each scenario is designed to test specific PAN products:

- **Cortex XDR**: Endpoint detection and response testing
- **PAN-OS**: Network security testing
- **Cortex XSIAM**: Security analytics testing
- **WildFire**: Malware analysis testing
- **Prisma Cloud**: Cloud security testing

## 📊 Monitoring & Logging

### Scenario Monitoring

- **Health Checks**: Regular health checks for all scenario components
- **Performance Monitoring**: Resource utilization monitoring
- **Attack Monitoring**: Attack activity monitoring
- **Network Monitoring**: Network traffic monitoring

### Logging Configuration

- **Scenario Logs**: Comprehensive scenario activity logging
- **Attack Logs**: Attack activity logging
- **Network Logs**: Network traffic logging
- **Security Logs**: Security event logging

## 🔒 Security Considerations

### Scenario Isolation

- **Network Isolation**: Isolated networks for different scenarios
- **Access Control**: Controlled access to scenario components
- **Data Protection**: Protection of sensitive data in scenarios
- **Cleanup Procedures**: Secure cleanup of scenario data

### Compliance

- **Scenario Authorization**: Proper authorization for all scenarios
- **Data Handling**: Proper handling of scenario data
- **Access Logging**: Comprehensive access logging
- **Audit Trails**: Complete audit trails for scenarios

## 🧪 Testing Integration

### PAN Product Integration

- **Cortex XDR**: Endpoint protection testing in scenarios
- **PAN-OS**: Network security testing in scenarios
- **WildFire**: Malware detection testing in scenarios
- **Cortex XSIAM**: Security analytics testing in scenarios

### Scenario Validation

- **Red Team Operations**: Realistic red team operations
- **APT Simulations**: Advanced persistent threat simulations
- **Social Engineering**: Social engineering testing
- **Malware Testing**: Malware testing scenarios

## 📚 Documentation

### Scenario Documentation

- **Scenario Specifications**: Detailed specifications for each scenario
- **Configuration Guides**: Step-by-step configuration guides
- **Troubleshooting Guides**: Common issues and solutions
- **Best Practices**: Best practices for scenario management

### Integration Documentation

- **PAN Product Integration**: Integration guides for PAN products
- **Testing Procedures**: Step-by-step testing procedures
- **Results Analysis**: Analysis of testing results
- **Lessons Learned**: Lessons learned from testing

## 🚨 Troubleshooting

### Common Issues

1. **Scenario Deployment Failures**
   - Check OpenShift cluster resources
   - Verify container image availability
   - Check network connectivity
   - Validate configuration files

2. **Scenario Performance Issues**
   - Monitor resource utilization
   - Check for resource constraints
   - Optimize container configurations
   - Scale resources as needed

3. **Integration Issues**
   - Verify PAN product connectivity
   - Check network policies
   - Validate security configurations
   - Test communication channels

### Debug Commands

```bash
# Check scenario deployment status
oc get pods -n baker-street-scenarios
oc logs -f deployment/scenario-component

# Check scenario network connectivity
oc exec -it scenario-pod -- ping target-system
oc exec -it scenario-pod -- curl target-service

# Check scenario resource usage
oc top pods -n baker-street-scenarios
oc describe pod scenario-pod
```

## 🔄 Updates & Maintenance

### Regular Maintenance

- **Scenario Updates**: Regular updates to scenario components
- **Security Patches**: Application of security patches
- **Configuration Updates**: Updates to scenario configurations
- **Documentation Updates**: Updates to scenario documentation

### Version Management

- **Scenario Versions**: Version control for scenario configurations
- **Image Management**: Management of scenario container images
- **Configuration Management**: Version control for configurations
- **Deployment Management**: Version control for deployments

## 🤝 Contributing

### Development Guidelines

1. **Scenario Standards**: Follow established scenario standards
2. **Documentation**: Include comprehensive documentation
3. **Testing**: Include testing procedures
4. **Security Review**: Security review for all scenarios

### Scenario Integration

When adding new scenarios to Baker Street Scenarios:

1. Create appropriate subdirectory
2. Include deployment configurations
3. Add comprehensive documentation
4. Include testing procedures
5. Update this README.md

## 📞 Support

### Getting Help

- **Documentation**: Check scenario-specific documentation
- **Logs**: Review scenario component logs
- **Community**: Engage with cyber range community
- **Issues**: Report issues through appropriate channels

### Contact Information

- **Project Maintainers**: Baker Street Labs Team
- **Documentation**: See individual scenario directories
- **Issues**: Repository issue tracking

---

**Baker Street Scenarios** - Where every investigation becomes a masterpiece of digital forensics and threat hunting.

*"The scenarios of our trade are as important as the tools that test them. In Baker Street Labs, we provide both."* - Sherlock Holmes 