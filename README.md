# Record Window

A daily snapshot runner for a separately configured collection pack. It loads a read-only pack on an ephemeral runner, calls its entry point, and retains an age-encrypted archive. Schedules use UTC (22:17 daily); manual runs use the same workflow. Archives expire after 60 days.

The pack is a GitHub repository with a default branch and a `run.sh OUTPUT_DIRECTORY` entry point. Set the repository secrets `PACK_REPO` (owner/name), `PACK_IDENTITY` (a read-only deploy key for that repository), and `RESULT_RECIPIENT` (an age public recipient). The decryption identity belongs to the operator and is never used on the runner. Collection inputs and plaintext records are not part of this repository.

If the pack reports a partial failure, the archive is still uploaded and the job reports failure. To read a downloaded archive: `age -d -i identity.txt output.age | tar -xz -C destination`. Create the destination first.
