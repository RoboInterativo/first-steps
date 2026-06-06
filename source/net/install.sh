#cert_path=/home/chief/projects/ssl
cert_path=/root/.acme.sh/robointerativo.org
cert_path2=/root/.acme.sh/robointerativo.ru
# helm uninstall nginx
helm upgrade --install   --debug -f values.yaml nginx .
#
# --set-file kas_certs.cert=/root/.acme.sh/kas.robointerativo.org/kas.robointerativo.org.cer \
# --set-file kas_certs.key=/root/.acme.sh/kas.robointerativo.org/kas.robointerativo.org.key \
# --set-file registry_certs.cert=/root/.acme.sh/registry.robointerativo.org/registry.robointerativo.org.cer \
# --set-file registry_certs.key=/root/.acme.sh/registry.robointerativo.org/registry.robointerativo.org.key \
# --set-file gitlab_certs.cert=/root/.acme.sh/gitlab.robointerativo.org/gitlab.robointerativo.org.cer \
# --set-file gitlab_certs.key=/root/.acme.sh/gitlab.robointerativo.org/gitlab.robointerativo.org.key \
# --set-file minio_certs.cert=/root/.acme.sh/gitlab.robointerativo.org/gitlab.robointerativo.org.cer  \
# --set-file minio_certs.key=/root/.acme.sh/gitlab.robointerativo.org/gitlab.robointerativo.org.key \
# --set-file certs.cert=$cert_path/robointerativo.org.cer \
# --set-file certs.key=$cert_path/robointerativo.org.key \
# --set-file certs2.cert=$cert_path2/robointerativo.ru.cer \
# --set-file certs2.key=$cert_path2/robointerativo.ru.key \
# --set-file team_certs.cert=/root/.acme.sh/team.robointerativo.org/team.robointerativo.org.cer \
# --set-file team_certs.key=/root/.acme.sh/team.robointerativo.org/team.robointerativo.org.key \
# --set-file wiki_certs.cert=/root/.acme.sh/wiki.robointerativo.org/wiki.robointerativo.org.cer \
# --set-file wiki_certs.key=/root/.acme.sh/wiki.robointerativo.org/wiki.robointerativo.org.key \
# --set-file jenkins_certs.cert=/root/.acme.sh/jenkins.robointerativo.org/jenkins.robointerativo.org.cer \
# --set-file jenkins_certs.key=/root/.acme.sh/jenkins.robointerativo.org/jenkins.robointerativo.org.key \
