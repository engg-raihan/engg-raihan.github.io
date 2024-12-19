// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateRegistry {

    address public admin; 

    struct Certificate {
        string certificateHash;    
        string fileUrl;           
        address owner;             
        address assigner;            
        uint64 timestamp;            
        string status;                 
    }

    mapping(string => Certificate) private certificates;

    // Event to log the addition of a new certificate, including the file URL
    event CertificateAdded(
        string indexed certId,
        address indexed owner,
        address indexed assigner,
        string certificateHash,
        string fileUrl,  
        uint256 timestamp,
        string status
    );

    // Event to log status updates
    event StatusUpdated(
        string indexed certId,
        string newStatus
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyAssignerOrOwner(string memory certId) {
        require(
            msg.sender == certificates[certId].assigner || msg.sender == certificates[certId].owner,
            "Only the assigner or the owner can update the status"
        );
        _;
    }

    constructor() {
        admin = msg.sender; 
    }

    function addCertificate(
        string memory _certId,
        string memory _certificateHash,
        string memory _fileUrl,
        address _assigner,
        string memory _status
    ) public onlyAdmin {
        require(certificates[_certId].timestamp == 0, "Certificate ID already exists.");

        certificates[_certId] = Certificate({
            certificateHash: _certificateHash,
            fileUrl: _fileUrl,
            owner: msg.sender,
            assigner: _assigner,
            timestamp: uint64(block.timestamp),
            status: _status
        });

        emit CertificateAdded(_certId, certificates[_certId].owner, _assigner, _certificateHash, _fileUrl, block.timestamp, _status);
    }

    function getCertificate(string memory _certId) public view returns (
        string memory certificateHash,
        string memory fileUrl,
        address owner,
        address assigner,
        uint256 timestamp,
        string memory status
    ) {
        require(certificates[_certId].timestamp != 0, "Certificate not found.");

        Certificate memory cert = certificates[_certId];
        return (
            cert.certificateHash,
            cert.fileUrl,
            cert.owner,
            cert.assigner,
            cert.timestamp,
            cert.status
        );
    }

    function updateStatus(string memory _certId, string memory _newStatus) public onlyAssignerOrOwner(_certId) {
        require(certificates[_certId].timestamp != 0, "Certificate not found.");

        certificates[_certId].status = _newStatus;
        emit StatusUpdated(_certId, _newStatus);
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "New admin address cannot be zero");
        admin = newAdmin;
    }
}
