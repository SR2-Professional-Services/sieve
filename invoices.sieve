# This script is for handling incoming invoices and statements, automatically forwarding
# incoming invoices to HubDoc where possible, or flagging for follow up.
# This will only occur where both SPF and DKIM checks have passed.
# A copy of each email will be saved to your Archive folder, or you can change this to
# use a different folder.
#
# Set the variables below before using this script yourself.

require ["fileinto", "imap4flags", "variables"];

# The mailbox you expect incoming invoices to be addressed to.
set "mailbox" "office@sr2pro.uk";

# Your HubDoc email address
# See: https://central.xero.com/s/article/Upload-or-email-documents-into-Hubdoc#EmailadocumenttoHubdoc
set "hubdoc" "example@app.hubdoc.com";

# The name of the folder to store emails after forwarding.
set "archive" "Archive";

# The label to apply to notifications requiring follow-up, e.g. log in to download PDF.
set "label" "$label4";

if allof (
  address :is "to" "${mailbox}",
  header :contains "Authentication-Results" "dkim=pass",
  header :contains "Authentication-Results" "spf=pass"
) {
  ####################
  # Anglia Registrars (Inform Direct) Invoice
  ####################
  if allof (
      address :is "from" "support@informdirect.co.uk",
      header :matches "Subject" "Inform Direct Invoice * for your records"
  ) {
    redirect "${hubdoc}";
    fileinto "${archive}";
  }
  ####################
  # Companies House Statement
  ####################
  if allof (
    address :is "from" "fssadmin@companieshouse.gov.uk",
    header :contains "Subject" "Statement available on Companies House Portal"
  ) {
    addflag "${label}";
  }
  ####################
  # GoCardless invoice
  ####################
  if allof (
    address :is "from" "no-reply@gocardless.com",
    header :contains "Subject" "Your GoCardless Invoice"
  ) {
    redirect "${hubdoc}";
    fileinto "${archive}";
  }
  ####################
  # Xero Invoice
  ####################
  if allof (
    address :is "from" "subscription.notifications@post.xero.com",
    header :matches "Subject" "Your Xero Invoice for "
  ) {
    addflag "${label}";
  }
}
